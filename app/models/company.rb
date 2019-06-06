class Company < ApplicationRecord
  has_many :users

  def self.create_company(data)
    if data
      code = SecureRandom.hex(10)

      create do |company|
        company.name = data["name"]
        company.email =  data["email"]
        company.phone = data["phone"]
        company.code = code
        company.save!
      end
    end
  end
end
