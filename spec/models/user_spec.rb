# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  encrypted_password :string(255)
#  salt               :string(255)
#

require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
        :name => "Example User",
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => 'foobar'
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_name_user = User.new(@attr.merge(:email => ""))
    no_name_user.should_not be_valid
  end

  it "should reject names that are too short" do
    short_name = "a" * 1
    short_name_user = User.new(@attr.merge(:name => short_name))
    short_name_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do
    it "should require a password" do
      no_password = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      no_password.should_not be_valid
    end

    it "should require a matching password confirmation" do
      bad_confirmation = User.new(@attr.merge(:password_confirmation => "invalid"))
      bad_confirmation.should_not be_valid
    end

    it "should reject passwords that are too short" do
      short_password = "a" * 5
      hash = User.new(@attr.merge(:password => short_password), :password_confirmation => short_password)
      hash.should_not be_valid
    end

    it "should reject passwords that are too long" do
      long_password = "a" * 41
      hash = User.new(@attr.merge(:password => long_password), :password_confirmation => long_password)
      hash.should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do
      it "should return nil if the password does not match the email address" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil if the email address does not exist" do
        nonexistent_user = User.authenticate("user@fake.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

end
