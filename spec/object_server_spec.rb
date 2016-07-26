#encoding: ASCII-8BIT

require 'knx/object_server'


describe "object server protocol helper" do
    before :each do
        @knx = KNX::ObjectServer.new
    end

    it "should parse and generate the same string" do
        datagram = @knx.read("\x06\x10\xF0\x80\x00\x15\x04\x00\x00\x00\xF0\x06\x00\x02\x00\x01\x00\x02\x03\x01\x01")
        expect(datagram.to_binary_s).to eq("\x06\x10\xF0\x80\x00\x15\x04\x00\x00\x00\xF0\x06\x00\x02\x00\x01\x00\x02\x03\x01\x01")

        expect(datagram.data[0].id).to eq(2)
        expect(datagram.data[0].value).to eq("\x01")
    end

    it "should generate single bit action requests" do
        datagram = @knx.action(1, false)
        expect(datagram.to_binary_s).to eq("\x06\x10\xF0\x80\x00\x15\x04\x00\x00\x00\xF0\x06\x00\x01\x00\x01\x00\x01\x03\x01\x00")

        datagram = @knx.action(2, true)
        expect(datagram.to_binary_s).to eq("\x06\x10\xF0\x80\x00\x15\x04\x00\x00\x00\xF0\x06\x00\x02\x00\x01\x00\x02\x03\x01\x01")
    end

    it "should generate byte action requests" do
        datagram = @knx.action(3, 20)
        expect(datagram.to_binary_s).to eq("\x06\x10\xF0\x80\x00\x15\x04\x00\x00\x00\xF0\x06\x00\x03\x00\x01\x00\x03\x03\x01\x14")

        datagram = @knx.action(4, 240)
        expect(datagram.to_binary_s).to eq("\x06\x10\xF0\x80\x00\x15\x04\x00\x00\x00\xF0\x06\x00\x04\x00\x01\x00\x04\x03\x01\xF0")
    end
end
