class CreateCountryStates < ActiveRecord::Migration
  def self.up
    create_table :country_states do |t|
      t.string :name
    end
    create_default
  end

  def self.down
    drop_table :country_states
  end
  def self.create_default
    clist = [ "Andra Pradesh",
         "Arunachal Pradesh",
         "Assam",
         "Bihar",
         "Chhattisgarh",
         "Goa",
         "Gujarat",
         "Haryana",
         "Himachal Pradesh",
         "Jammu and Kashmir",
         "Jharkhand",
         "Karnataka",
         "Kerala",
         "Madya Pradesh",
         "Maharashtra",
         "Manipur",
         "Meghalaya",
         "Mizoram",
         "Nagaland",
         "Orissa",
         "Punjab",
         "Rajasthan",
         "Sikkim",
         "Tamil Nadu",
         "Tripura",
         "UttraKhand",
         "Uttar Pradesh",
         "West Bengal",
         "Andaman and Nicobar Islands",
         "Chandigarh",
         "Dadar and Nagar Haveli",
         "Daman and Diu",
         "Delhi",
         "Lakshadeep",
         "Pondicherry"
         ]
       
    clist.each do |c|
      @c1 = CountryState.new
      @c1.name = c
      @c1.save
    end
  end
end
