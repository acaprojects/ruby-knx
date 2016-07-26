# encoding: ASCII-8BIT
# frozen_string_literal: true

require 'bindata'

require 'knx/header'
require 'knx/cemi'
require 'knx/address'
require 'knx/datagram'


class KNX
    Defaults = {
        priority: :low,
        no_repeat: true,
        broadcast: true,
        hop_count: 6,
        msg_code: :data_indicator
    }

    def initialize(options = {})
        @options = Defaults.merge(options)
    end

    # Builds a KNX command datagram for setting an address to a value
    #
    # @param address [String] the object address in group or individual format
    # @param data [String, Integer, Fixnum, Array<Integer, Fixnum>] the value to be set at the address
    # @return [ActionDatagram] a ruby object representing the request that can be modified further
    def action(address, data, options = {})
        if data == true || data == false
            data = data ? 1 : 0
        end

        klass = data.class

        raw = if klass == String
            data.bytes
        elsif [Integer, Fixnum].include? klass
            # Assume this is a byte
            [data]
        elsif klass == Array
            # We assume this is a byte array
            data
        else
            raise ArgumentError, "Unknown data type for #{data}"
        end

        ActionDatagram.new(address, raw, @options.merge(options))
    end

    # Builds a KNX status request datagram for querying an address value
    #
    # @param address [String] the object address in group or individual format
    # @return [StatusDatagram] a ruby object representing the request that can be modified further
    def status(address, options = {})
        StatusDatagram.new(address, @options.merge(options))
    end

    # Represents a KNX datagram as a ruby object for easy inspection
    #
    # @param data [String] a binary string containing the datagram
    # @return [ResponseDatagram] a ruby object representing the data
    def read(data, options = {})
        ResponseDatagram.new(data, @options.merge(options))
    end
end
