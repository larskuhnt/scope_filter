require 'spec_helper'

setup_database

class Person < ActiveRecord::Base
  include ScopeFilter::ActiveRecord
  
  scope :dwarf,      where('age > ? AND height < ?', 16, 150)
  scope :bastard,    where('lastname IN (?)', %w(Snow Sand Rivers))
  scope :highborn,   where('lastname IN (?)', %w(Lannister Stark Targaryen Martell))
  scope :older_than, lambda { |age| where('age > ?', age) }
  scope :dead,       where('date_of_death IS NOT NULL')
  scope :dragon,     where('lastname = ?', 'Targaryen')
  
  configure_scope_filter do |config|
    config.add_scopes :dwarf, :bastard, :dead, :highborn
    config.add_scope  :older_than, true
    config.like       :firstname
    config.eq         :knight
    config.like       :firstname_ends_with, :field => 'firstname', :pattern => lambda { |v| "%#{v}" }
    config.null       :alive, :field => 'date_of_death'
    config.sortable   :lastname, :firstname
  end

end

describe ScopeFilter::ActiveRecord do
  
  before :all do
    @users = [
      Factory(:person, :id => 1,  :firstname => 'Tyrion',   :lastname => 'Lannister', :age => 302-274, :height => 135, :knight => false, :date_of_death => nil),
      Factory(:person, :id => 2,  :firstname => 'Arya',     :lastname => 'Stark',     :age => 302-289, :height => 147, :knight => false, :date_of_death => nil),
      Factory(:person, :id => 3,  :firstname => 'Brandon',  :lastname => 'Stark',     :age => 302-290, :height => 152, :knight => false, :date_of_death => nil),
      Factory(:person, :id => 4,  :firstname => 'Nymeria',  :lastname => 'Sand',      :age => 302-275, :height => 171, :knight => false, :date_of_death => nil),
      Factory(:person, :id => 5,  :firstname => 'Jon',      :lastname => 'Snow',      :age => 302-283, :height => 182, :knight => false, :date_of_death => nil),
      Factory(:person, :id => 6,  :firstname => 'Daenerys', :lastname => 'Targaryen', :age => 302-284, :height => 174, :knight => false, :date_of_death => nil),
      Factory(:person, :id => 7,  :firstname => 'Oberyn',   :lastname => 'Martell',   :age => 302-258, :height => 178, :knight => false, :date_of_death => Date.civil(300)),
      Factory(:person, :id => 8,  :firstname => 'Jaime',    :lastname => 'Lannister', :age => 302-266, :height => 186, :knight => true,  :date_of_death => nil),
      Factory(:person, :id => 9,  :firstname => 'Brynden',  :lastname => 'Rivers',    :age => 302-175, :height => 181, :knight => true,  :date_of_death => Date.civil(300)),
      Factory(:person, :id => 10, :firstname => 'Gregor',   :lastname => 'Clegane',   :age => 302-266, :height => 203, :knight => true,  :date_of_death => Date.civil(300))
    ]
  end
  
  after :all do
    Person.destroy_all
  end
  
  it "should be stored in the db" do
    Person.find(@users.first.id).should_not be_nil
  end
  
  it "should respond to scope_filter" do
    lambda {
      Person.scope_filter
    }.should_not raise_error
  end
  
  it "should return all persons for empty params" do
    Person.scope_filter().size.should == @users.size
  end
  
  it "should ignore illegal fields" do
    Person.scope_filter(:id => @users.first.id).size.should == @users.size
  end
  
  it "should ignore illegal scopes" do
    Person.scope_filter(:dragon => true).size.should == @users.size
  end
  
  it "should return 3 persons for bastard scope" do
    Person.scope_filter(:bastard => true).size.should == 3
  end
  
  it "should return Tyrion for dwarf scope" do
    Person.scope_filter(:dwarf => true).should == [@users.first]
  end
  
  it "should return 6 persons older_than 20 scope" do
    Person.scope_filter(:older_than => 20).size.should == 6
  end
  
  it "should return 2 dead persons older_than 40" do
    Person.scope_filter(:older_than => 40, :dead => true).size.should == 2
  end
  
  it "should filter 2 persons whos firstname ends with 'a'" do
    Person.scope_filter(:firstname_ends_with => 'a').size.should == 2
  end
  
  it "should filter 5 persons whos firstname contains 'a'" do
    Person.scope_filter(:firstname => 'a').size.should == 5
  end
  
  it "should filter 3 knights" do
    Person.scope_filter(:knight => true).size.should == 3
  end
  
  it "should filter Brynden as bastard knights" do
    Person.scope_filter(:bastard => true, :knight => true).should == [@users[8]]
  end
  
  it "should filter Jaime highborn knights" do
    Person.scope_filter(:highborn => true, :knight => true).should == [@users[7]]
  end
  
  it "should sort 3 knights ascending by lastname" do
    Person.scope_filter(:knight => true, :_sort => :lastname_asc).should == [@users[9], @users[7], @users[8]]
  end
  
  it "should sort 3 knights descending by firstname" do
    Person.scope_filter(:knight => true, :_sort => :firstname_desc).should == [@users[7], @users[9], @users[8]]
  end
  
  it "should ignore illegal sort fields" do
    Person.scope_filter(:knight => true, :_sort => :age_desc).should == [@users[7], @users[8], @users[9]]
  end
  
end