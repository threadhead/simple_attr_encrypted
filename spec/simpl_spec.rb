require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveRecord::SimpleAttrEncrypted do
  before(:all) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

    ActiveRecord::Schema.define(:version => 2) do
      create_table :encryptable_items do |t|
        t.string :encrypted_item
        t.string :encrypted_item_iv
        t.string :encrypted_item2
        t.string :encrypted_item2_iv
      end
    end

    class EncryptableItem < ActiveRecord::Base
      include ActiveRecord::SimpleAttrEncrypted
      encrypted_attribute 'item'
      encrypted_attribute 'item2'
    end
  end

  after(:all) do
    ActiveRecord::Base.clear_active_connections!
  end

  before(:each) do
    @ei = EncryptableItem.create!
  end

  subject { @ei }

  context 'new resources' do
    its('encrypted_item_iv') { should_not be_empty }
  end

  context 'encrypted_attribute' do
    before do
      @ei.item = "daiseies"
      @ei.save
    end

    it 'returns an encrypted item' do
      @ei.encrypted_item.should_not be_empty
    end

    it 'does not store the item unencrypted' do
      @ei.encrypted_item.should_not eq('daiseies')
    end

    it 'returns the decrypted item' do
      @ei.item.should eq("daiseies")
    end

    it 'returns empty string if empty' do
      @ei.item = ""
      @ei.save
      @ei.item.should be_empty
    end

    it 'returns nil string if nill' do
      @ei.item = nil
      @ei.save
      @ei.item.should be_nil
    end


  end

  context 'additional encrypted_attribute' do
    its('encrypted_item2_iv') { should_not be_empty }
    its('encrypted_item2_iv') { should_not eq(@ei.encrypted_item_iv) }

    context 'item2 attribute' do
      before do
        @ei.item = "daiseies"
        @ei.item2 = "moosedrool"
        @ei.save
      end

      it 'returns an encrypted item' do
        @ei.encrypted_item2.should_not be_empty
      end

      it 'does not store the item unencrypted' do
        @ei.encrypted_item2.should_not eq('moosdrool')
      end

      it 'returns the decrypted item' do
        @ei.item2.should eq("moosedrool")
      end

      it 'different from item' do
        @ei.item2.should_not eq(@ei.item)
        @ei.encrypted_item2.should_not eq(@ei.encrypted_item)
      end

    end
  end

end
