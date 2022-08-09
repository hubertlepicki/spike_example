defmodule SpikeExample.SimpleForm do
  use Spike.Form do
    field :first_name, :string
    field :last_name, :string
    field :email_address, :string
    field :password, :string
    field :accepts_conditions, :boolean, default: false
  end

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates(:email_address,
    presence: true,
    format: [with: ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, allow_blank: true]
  )

  validates(:accepts_conditions, acceptance: true)
  validates(:password, presence: true, length: [min: 8, allow_blank: true])
end
