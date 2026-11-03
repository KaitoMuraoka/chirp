class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy

  validates :body, presence: true, length: { maximum: 140 }

  scope :timeline, -> { includes(:user, :likes).order(created_at: :desc) }

  def liked_by?(user)
    likes.any? { |like| like.user_id == user.id }
  end
end
