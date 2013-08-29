require 'contracts'
require 'error/paynet_error'

module PaynetEasy::PaynetEasyApi::Transport
  class Response
    include Contracts
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

    Contract String => Any
    def needed_action=(needed_action)
      unless @@allowed_needed_actions.include? needed_action
        raise ArgumentError, "Unknown needed action: '#{needed_action}'"
      end

      @needed_action = needed_action
    end

    Contract None => Bool
    def status_update_needed?
      needed_action == NEEDED_STATUS_UPDATE
    end

    Contract None => Bool
    def show_html_needed?
      needed_action == NEEDED_SHOW_HTML
    end

    Contract None => Bool
    def redirect_needed?
      needed_action == NEEDED_REDIRECT
    end

    Contract None => Maybe[String]
    def html
      fetch 'html', nil
    end

    Contract None => Bool
    def has_html?
      !html.nil?
    end

    Contract None => Maybe[String]
    def type
      fetch('type').downcase if key? 'type'
    end

    Contract None => Maybe[String]
    def status
      if !fetch('status', nil) && !%w(validation-error error).include?(type)
        store 'status', 'processing'
      end

      fetch('status').downcase if key? 'status'
    end

    Contract None => Bool
    def approved?
      status == 'approved'
    end

    Contract None => Bool
    def processing?
      status == 'processing'
    end

    Contract None => Bool
    def declined?
      %w(filtered declined).include? status
    end

    Contract None => Maybe[String]
    def payment_client_id
      any_key %w(merchant-order-id client_orderid merchant_order)
    end

    Contract None => Maybe[String]
    def payment_paynet_id
      any_key %w(orderid paynet-order-id)
    end

    Contract None => Maybe[String]
    def card_paynet_id
      fetch 'card-ref-id', nil
    end

    Contract None => Maybe[String]
    def redirect_url
      fetch 'redirect-url', nil
    end

    Contract None => Bool
    def has_redirect_url?
      !redirect_url.nil?
    end

    Contract None => Maybe[String]
    def control_code
      any_key %w(control merchant_control)
    end

    Contract None => Maybe[String]
    def error_message
      any_key %w(error_message error-message)
    end

    Contract None => Maybe[Integer]
    def error_code
      any_key %w(error_code error-code)
    end

    Contract None => Bool
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

    Contract Array => Any
    def any_key(keys)
      keys.each {|key| return fetch key if key? key}
      nil # if all keys missed in data
    end
  end
end