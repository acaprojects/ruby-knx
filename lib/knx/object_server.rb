# encoding: ASCII-8BIT
# frozen_string_literal: true

require 'bindata'

require 'knx/header'
require 'knx/object_server/object_header'
require 'knx/object_server/status_item'
require 'knx/object_server/request_item'
require 'knx/object_server/datagram'


class KNX
    class ObjectServer
        Defaults = {
            filter: :valid_values,
            item_count: 1,
            command: :set_value_and_send
        }

        def initialize(options = {})
            @options = Defaults.merge(options)
        end

        # Builds an Object Server command datagram for setting an index to a value
        #
        # @param index [Integer, Fixnum] the object address or index as defined in the object server
        # @param data [String, Integer, Fixnum, Array<Integer, Fixnum>] the value to be set at the address
        # @return [Datagram] a ruby object representing the request that can be modified further
        def action(index, data = nil, **options)
            options = @options.merge(options)

            cmd = Datagram.new
            cmd.add_action(index.to_i, data: data, **options)
            cmd.header.sub_service = 0x06
            cmd.header.start_item = index.to_i
            cmd
        end

        # Builds an Object Server request datagram for querying an index value
        #
        # @param index [Integer, Fixnum] the object address or index as defined in the object server
        # @return [Datagram] a ruby object representing the request that can be modified further
        def status(index, options = {})
            options = @options.merge(options)

            data = Datagram.new
            data.header.sub_service = 0x05
            data.header.start_item = index.to_i
            data.header.item_count = options[:item_count].to_i
            data.header.filter = Filters[options[:filter]]
            data
        end

        # Returns a KNX Object Server datagram as a ruby object for easy inspection
        #
        # @param data [String] a binary string containing the datagram
        # @return [Datagram] a ruby object representing the data
        def read(raw_data)
            Datagram.new(raw_data)
        end
    end
end
