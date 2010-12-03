require 'rubygems'
require 'sqlite3'
require 'active_record'
require 'mutability'

# connect to database.  This will create one if it doesn't exist
MUTABILITY_TEST_DB_NAME = ".mutability_test.db"
MUTABILITY_TEST_DB = SQLite3::Database.new(MUTABILITY_TEST_DB_NAME)

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MUTABILITY_TEST_DB_NAME)

class Person < ActiveRecord::Base
  attr_accessor :immutable
  make_immutable_when {|person| person.immutable }
end

# do a quick pseudo migration.  This should only get executed on the first run
if !Person.table_exists?
  ActiveRecord::Base.connection.create_table(:people) do |t|
    t.column :name, :string
  end
end

describe Person do
  context "when immutable then" do
    before(:each) do
      @person = Person.new(:immutable => true)
    end

    it 'raises ActiveRecord::ReadOnlyRecord exception when a save is attempted' do  
      lambda { @person.save }.should raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it 'raises ActiveRecord::ReadOnlyRecord exception when a destroy is attemted' do
      lambda { @person.destroy }.should raise_error(ActiveRecord::ReadOnlyRecord)
    end    
  end

  context "when mutable then" do
    before(:each) do
      @person = Person.new(:immutable => false)
    end

    it 'doesn\'t raise exception when a save is attempted' do
      @person.save.should be_true
    end

    it 'doesn\'t raise exception when a destroy is attemted' do
      @person.save
      @person.destroy
      @person.frozen?.should be_true
    end    
  end
end

