require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe VCAP::Logging::Formatter::DelimitedFormatter do
  describe '#initialize' do

    it 'should define a format_record' do
      fmt = VCAP::Logging::Formatter::DelimitedFormatter.new {}
      fmt.respond_to?(:format_record).should be_true
    end

  end

  describe '#format_record' do
    it 'should return a correctly formatted message' do
      rec = VCAP::Logging::LogRecord.new(:debug, 'foo', VCAP::Logging::Logger.new('foo', nil), ['bar', 'baz'])
      fmt = VCAP::Logging::Formatter::DelimitedFormatter.new('.') do
        timestamp '%s'
        log_level
        tags
        process_id
        thread_id
        data
      end

      fmt.format_record(rec).should == [rec.timestamp.strftime('%s'), ' DEBUG', 'bar,baz', rec.process_id.to_s, rec.thread_id.to_s, 'foo'].join('.') + "\n"
    end

    it 'should encode newlines' do
      rec = VCAP::Logging::LogRecord.new(:debug, "test\ning123\n\n", VCAP::Logging::Logger.new('foo', nil), [])
      fmt = VCAP::Logging::Formatter::DelimitedFormatter.new('.') { data }
      fmt.format_record(rec).should == "test\\ning123\\n\\n\n"
    end

    it 'should format exceptions' do
      begin
        raise StandardError, "Testing 123"
      rescue => exc
      end
      rec = VCAP::Logging::LogRecord.new(:error, exc, VCAP::Logging::Logger.new('foo', nil), [])
      fmt = VCAP::Logging::Formatter::DelimitedFormatter.new('.') { data }
      fmt.format_record(rec).should == "StandardError(\"Testing 123\", [#{exc.backtrace.join(',')}])\n"
    end
  end
end
