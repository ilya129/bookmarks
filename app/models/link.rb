class Link < ApplicationRecord
  STOPWORDS = %w(links users user link)

  DOMAIN_REGEXP = /\A#{URI::RFC2396_REGEXP::PATTERN::HOSTNAME}\Z/

  belongs_to :user

  validates :name, uniqueness: {scope: [:domain]}
  validates :name, length: {maximum: 90}
  validates :name, format: {with: /\A\w+\Z/i}
  validates :name, :url, presence: true
  validate :name_allowed

  validates :url, length: {maximum: 1023}
  validate :url_allowed

  validates :domain, presence: true, allow_nil: true, allow_blank: false
  validates :domain, format: {with: DOMAIN_REGEXP}, allow_nil: true

  before_validation :set_unique_name, on: :create
  before_validation :downcase_domain

  private

  def set_unique_name
    self.name = unique_url(domain) unless name.present?
  end

  def downcase_domain
    self.domain = domain.downcase if domain
  end

  def name_allowed
    errors.add(:name, :stopwords) if STOPWORDS.include?(name.try(:downcase))
  end

  def unique_url(domain)
    token = ''
    links_count = Link.where(domain: domain).count

    key_length = case links_count
                 when 0..500
                   2
                 when 501..20000
                   3
                 when 20001..400_000
                   4
                 when 400_001..10_000_000
                   5
                 else
                   6
                 end

    5.times do
      token = Link.random_token(key_length)
      return token unless Link.where(name: token, domain: domain).exists?
    end
    errors.add(:name, :not_generated)
    nil
  end

  def url_allowed
    unless Link.valid_url?(url)
      http_url = "http://#{url}"

      if Link.valid_url?(http_url)
        self.url = http_url
      else
        errors.add(:url, :invalid)
      end
    end
  end

  def self.valid_url?(url)
    uri = URI.parse(url)
    !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def self.random_token(key_length)
    SecureRandom.urlsafe_base64(key_length).tr('lIO0-', 'sxyz_')
  end
end
