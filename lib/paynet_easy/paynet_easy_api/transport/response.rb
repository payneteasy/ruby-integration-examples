require 'error/paynet_error'

module PaynetEasy::PaynetEasyApi::Transport
  class Response
    include PaynetEasy::PaynetEasyApi::Error

    # Need to update payment status
    NEEDED_STATUS_UPDATE  = 'status_update'

    # Need to show html from response
    NEEDED_SHOW_HTML      = 'show_html'

    # Need redirect to response url
    NEEDED_REDIRECT       = 'redirect'

    @@allowed_needed_actions =
    [
        NEEDED_STATUS_UPDATE,
        NEEDED_SHOW_HTML,
        NEEDED_REDIRECT
    ]

    attr_accessor :needed_action

    def initialize(response = {})
      @data = Hash[response.map {|key, value| [key, value.to_s.strip]}]
    end

    def needed_action=(needed_action)
      unless @@allowed_needed_actions.include? needed_action
        raise ArgumentError, "Unknown needed action: '#{needed_action}'"
      end

      @needed_action = needed_action
    end

    def status_update_needed?
      needed_action == NEEDED_STATUS_UPDATE
    end

    def show_html_needed?
      needed_action == NEEDED_SHOW_HTML
    end

    def redirect_needed?
      needed_action == NEEDED_REDIRECT
    end

    def html
      fetch 'html', nil
    end

    def has_html?
      !html.nil?
    end

    def type
      fetch('type').downcase if key? 'type'
    end

    def status
      if !fetch('status', nil) && !%w(validation-error error).include?(type)
        store 'status', 'processing'
      end

      fetch('status').downcase if key? 'status'
    end

    def approved?
      status == 'approved'
    end

    def processing?
      status == 'processing'
    end

    def declined?
      %w(filtered declined).include? status
    end

    def payment_client_id
      any_key %w(merchant-order-id client_orderid merchant_order)
    end

    def payment_paynet_id
      any_key %w(orderid paynet-order-id)
    end

    def card_paynet_id
      fetch 'card-ref-id', nil
    end

    def redirect_url
      fetch 'redirect-url', nil
    end

    def has_redirect_url?
      !redirect_url.nil?
    end

    def control_code
      any_key %w(control merchant_control)
    end

    def error_message
      any_key %w(error_message error-message)
    end

    def error_code
      any_key %w(error_code error-code)
    end

    def error?
      %w(validation-error error).include?(type) || status == 'error'
    end

    def error
      if error? || declined?
        PaynetError.new error_message
      else
        raise RuntimeError, 'Response has no error'
      end
    end

    def method_missing(name, *args, &block)
      @data.send name, *args, &block
    end

    protected

    def any_key(keys)
      keys.each {|key| return fetch key if key? key}
      nil # if all keys missed in data
    end
  end
end