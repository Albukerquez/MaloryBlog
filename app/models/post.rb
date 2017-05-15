# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  title            :string
#  body             :text
#  description      :text
#  slug             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  banner_image_url :string
#  author_id        :integer
#  published        :boolean          default("false")
#  published_at     :datetime
#

class Post < ApplicationRecord
  acts_as_taggable # Alias for acts_as_taggable_on :tags

  list = lambda do |page, tag|
    recent_paginated(page).with_tag(tag)
  end

  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :author

  PER_PAGE = 10

  scope :most_recent, (-> { order(published_at: :desc) })
  scope :published, (-> { where(published: true) })
  scope :recent_paginated, (->(page) { most_recent.paginate(page: page, per_page: PER_PAGE) })
  scope :with_tag, (->(tag) { tagged_with(tag) if tag.present? })
  scope :list_for, list

  def should_generate_new_friendly_id?
    title_changed?
  end

  def display_day_published
    if published_at.present?
      "Опубликовано #{published_at.strftime('%-b %-d, %Y')}"
    else
      'Not published yet.'
    end
  end

  def display_updated_at
    "Последнее обновление #{updated_at.strftime('%-b %-d, %Y')}" if updated_at.present?
  end

  def publish
    update(published: true, published_at: Time.now)
  end

  def unpublish
    update(published: false, published_at: nil)
  end
end
