class CreateEosRamPriceHistories < ActiveRecord::Migration[5.2]
  def change
    # Define new domain for price field which cannot be zero and be negative.
    execute "CREATE DOMAIN positive_8 AS decimal(38, 8) CHECK (VALUE > 0)"

    create_table :eos_ram_price_histories, id: false do |t|
      t.integer :intvl, unsigned: true, null: false
      t.column :start_time, :timestamp, null: false
      t.column :end_time, :timestamp, null: false

      t.column :open, :positive_8, null: false 
      t.column :close, :positive_8, null: false
      t.column :high, :positive_8, null: false
      t.column :low, :positive_8, null: false

      t.timestamps
    end

    # Set a primary key.
    execute "ALTER TABLE eos_ram_price_histories ADD PRIMARY KEY (intvl, start_time);"

    # A helper function for verifying whether start time is a multiple of intvls.
    execute "
      CREATE OR REPLACE FUNCTION time_floor(seconds int, t timestamp) RETURNS timestamp AS $$
        DECLARE
          n int;
        BEGIN
          RETURN to_timestamp(floor(extract(epoch from t) / seconds) * seconds);
        END;
      $$ LANGUAGE plpgsql IMMUTABLE;"
    
    # Start time must be a multiple of intvl.
    execute "ALTER TABLE eos_ram_price_histories ADD CONSTRAINT start_time_correct CHECK( time_floor(intvl, start_time) = start_time )"
    # End time should be start time + intvl.
    execute "ALTER TABLE eos_ram_price_histories ADD CONSTRAINT end_time_correct CHECK( start_time + interval '1 second' * intvl = end_time)"
    # High has to be the highest price.
    execute "ALTER TABLE eos_ram_price_histories ADD CONSTRAINT high_correct CHECK( greatest(open, close, high, low) = high )"
    # Low must be the lowest price.
    execute "ALTER TABLE eos_ram_price_histories ADD CONSTRAINT low_correct CHECK( (least(open, close, high, low) = low) AND (low > 0) )"

    # A helper function for dealing with price histories.
    execute "CREATE OR REPLACE FUNCTION upsert_eos_ram_price_histories(a_exec_at timestamp, a_price positive_8) RETURNS void AS $$
      DECLARE
        v_intvl integer;
      BEGIN
        INSERT INTO eos_ram_price_histories(intvl, start_time, end_time, open, close, high, low)
          SELECT sub.seconds, sub.start_time, sub.start_time + seconds * interval '1 second',
            a_price, a_price, a_price, a_price
            FROM (SELECT seconds, time_floor(seconds, a_exec_at) as start_time FROM price_history_intvls) AS sub
        ON CONFLICT (intvl, start_time)
          DO UPDATE SET
            close = a_price,
            high = GREATEST(price_histories.high, a_price),
            low = LEAST(price_histories.low, a_price);
        RETURN;
      END;
      $$ LANGUAGE plpgsql;"
  end
end
