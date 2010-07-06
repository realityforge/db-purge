class DbPurge
  class << self

    def define_tableset(key, tables)
      tableset_map[key] = tables
    end

    def uses_transaction
      raise "Attempted to call uses_transaction without starting session" if !@active
      @clean = false
    end

    def start(table_set_key = :default)
      raise "Attempted to start database cleaner without finishing last session" if @active
      #puts "DbCleaner.start"
      clean(table_set_key)
      @active = true
      if ActiveRecord::Base.connection.respond_to?(:increment_open_transactions)
        ActiveRecord::Base.connection.increment_open_transactions
      else
        ActiveRecord::Base.__send__(:increment_open_transactions)
      end

      ActiveRecord::Base.connection.begin_db_transaction
    end

    def finish
      raise "Attempted to finish database cleaner without starting session" if !@active
      #puts "DbCleaner.finish"
      @active = false
      ActiveRecord::Base.connection.rollback_db_transaction

      if ActiveRecord::Base.connection.respond_to?(:decrement_open_transactions)
        ActiveRecord::Base.connection.decrement_open_transactions
      else
        ActiveRecord::Base.__send__(:decrement_open_transactions)
      end
    end

    private

    def tableset_map
      @tablesets ||= {:default => []}
    end

    def clean(table_set_key)
      if !@clean
        #puts "DbCleaner.clean"
        tables = tableset_map[table_set_key]
        raise "Unable to locate tableset #{table_set_key.inspect}" unless tables
        tables.each do |table|
          ::ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
        end
        @clean = true
      end
    end
  end
end