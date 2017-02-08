module NiftyServices
  class BaseService

    @@registered_callbacks = Hash.new {|k,v| k[v] = Hash.new }

    CALLBACKS = [
      :before_execute_service_action,
      :after_execute_service_action,
      :before_delete_record,
      :after_delete_record,
      :before_update_record,
      :after_update_record,
      :before_build_record,
      :after_build_record,
      :before_initialize,
      :after_initialize,
      :before_execute,
      :after_execute,
      :before_success,
      :after_success,
      :before_error,
      :after_error,
      :before_create,
      :after_create,
      :before_update,
      :after_update,
      :before_delete,
      :after_delete,
      :before_action,
      :after_action
    ].freeze

    class << self
      def register_callback(callback_name, method_name, &block)
        method_name = Util.normalized_callback_name(method_name)

        @@registered_callbacks[self.name.to_sym][callback_name] ||= []
        @@registered_callbacks[self.name.to_sym][callback_name] << method_name

        register_callback_action(method_name, &block)
      end

      def register_callback_action(callback_name, &block)
        define_method(callback_name, &block)
      end

      CALLBACKS.each do |callback_name|
        define_method callback_name do |&block|
          register_callback_action(callback_name, &block)
        end
      end
    end

    def callback_fired?(callback_name)
      return (
              callback_fired_in?(@fired_callbacks, callback_name) ||
              callback_fired_in?(@custom_fired_callbacks, callback_name) ||
              callback_fired_in?(@custom_fired_callbacks, "#{callback_name}_callback")
             )
    end

    alias :callback_called? :callback_fired?

    def register_callback(callback_name, method_name, &block)
      method_name = normalized_callback_name(method_name).to_sym

      @registered_callbacks[callback_name.to_sym] << method_name
      register_callback_action(callback_name, &block)
    end

    def register_callback_action(callback_name, &block)
      cb_name = normalized_callback_name(callback_name).to_sym
      @callbacks_actions[cb_name.to_sym] = block
    end

    private
    def callbacks_setup
      return nil if @callbacks_setup

      @fired_callbacks, @custom_fired_callbacks = {}, {}
      @callbacks_actions = {}
      @registered_callbacks ||= Hash.new {|k,v| k[v] = [] }

      @callbacks_setup = true
    end

    def call_callback(callback_name)
      callback_name = callback_name.to_s.underscore.to_sym

      @fired_callbacks[callback_name.to_sym] = true

      try_to_invoke_callback(callback_name)

      call_registered_callbacks_for(callback_name)

      # allow chained methods
      self
    end


    def has_callback_method?(callback_name)
      return true if respond_to?(callback_name, true)

      return respond_to?(normalized_callback_name(callback_name), true)
    end

    def with_before_and_after_callbacks(callback_basename, &block)
      call_callback(:"before_#{callback_basename}")

      block_response = yield(block) if block_given?

      call_callback(:"after_#{callback_basename}")

      block_response
    end

    def call_registered_callbacks_for(callback_name)
      instance_call_all_custom_registered_callbacks_for(callback_name)
      class_call_all_custom_registered_callbacks_for(callback_name)
    end

    def instance_call_all_custom_registered_callbacks_for(callback_name)
      callbacks = @registered_callbacks[callback_name.to_sym]

      callbacks.each do |cb|
        if callback = @callbacks_actions[cb.to_sym]
          @custom_fired_callbacks[cb.to_sym] = true
          invoke_callback(callback)
        end
      end
    end

    def class_call_all_custom_registered_callbacks_for(callback_name)
      @@registered_callbacks.each do |klass, _|
        class_call_all_custom_registered_callbacks_for_class(klass, callback_name)
      end
    end

    def class_call_all_custom_registered_callbacks_for_class(class_name, callback_name)
      class_callbacks = @@registered_callbacks[class_name.to_sym]
      callbacks = class_callbacks[callback_name.to_sym]

      return nil unless callbacks

      callbacks.each do |cb|
        @custom_fired_callbacks[cb.to_sym] = true
        try_to_invoke_callback(cb)
      end
    end

    def try_to_invoke_callback(cb)
      return nil unless has_callback_method?(cb)

      invoke_callback(method(cb))
    end

    def callback_fired_in?(callback_list, callback_name)
      return callback_list.key?(callback_name.to_sym)
    end

    def normalized_callback_name(callback_name, suffix = '_callback')
      Util.normalized_callback_name(callback_name, suffix)
    end

    def invoke_callback(method)
      method.call
    end
  end
end
