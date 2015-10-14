module DbPurge
  class << self

    def define_tableset(key, tables)
      tableset_map[key] = tables
    end

    def uses_transaction
      raise "Attempted to call uses_transaction without starting session" if !@active
      #puts 'DbCleaner.uses_transaction'
      @clean = false
      rollback_transaction
    end

    def start(table_set_key = :default)
      raise "Attempted to start database cleaner without finishing last session" if @active
      #puts "DbCleaner.start"
      clean(table_set_key)
      @active = true
      start_transaction
    end

    def finish
      raise "Attempted to finish database cleaner without starting session" if !@active
      #puts "DbCleaner.finish"
      @active = false
      rollback_transaction if @in_transaction
    end

    private

    def start_transaction
      raise "Attempted to start a transaction while already in transaction" if @in_transaction
      @in_transaction = true
      if ActiveRecord::Base.connection.respond_to?(:increment_open_transactions)
        ActiveRecord::Base.connection.increment_open_transactions
      else
        ActiveRecord::Base.__send__(:increment_open_transactions)
      end

      ActiveRecord::Base.connection.begin_db_transaction
    end

    def rollback_transaction
      raise "Attempted to rollback a transaction while not in a transaction" if !@in_transaction
      @in_transaction = false
      ActiveRecord::Base.connection.rollback_db_transaction

      if ActiveRecord::Base.connection.respond_to?(:decrement_open_transactions)
        ActiveRecord::Base.connection.decrement_open_transactions
      else
        ActiveRecord::Base.__send__(:decrement_open_transactions)
      end
    end

    def tableset_map
      @tablesets ||= {:default => []}
    end

    def clean(table_set_key)
      unless @clean
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
