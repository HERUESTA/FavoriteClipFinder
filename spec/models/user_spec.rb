require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '設定したすべてのバリデーションが機能しているか' do
      user = build(:user)
      expect(user).to be_valid
      expect(user.errors).to be
    end

    it 'user_nameが空欄の場合バリデーションが通らない' do
      user_without_user_name = build(:user, user_name: nil)
      expect(user_without_user_name).to be_invalid
      expect(user_without_user_name.errors[:user_name]).to include("は4文字以上で入力してください")
    end

    it 'user_nameが21文字以上の場合バリデーションが通らない' do
      user_over_user_name = build(:user, user_name: "a" * 21)
      expect(user_over_user_name).to be_invalid
      expect(user_over_user_name.errors[:user_name]).to include("は20文字以内で入力してください")
    end

    it 'emailが空欄の場合バリデーションが通らない' do
      user_without_email = build(:user, email: nil)
      expect(user_without_email).to be_invalid
      expect(user_without_email.errors[:email]).to include("を入力してください")
    end

    it 'emailが256文字以上の場合バリデーションが通らない' do
      user_over_email = build(:user, email: "a" * 244 + "@example.com")
      expect(user_over_email).to be_invalid
      expect(user_over_email.errors[:email]).to include("は255文字以内で入力してください")
    end

    it 'emailが正しい形式でない場合バリデーションが通らない' do
      user_invalid_email = build(:user, email: "user@example,com")
      expect(user_invalid_email).to be_invalid
      expect(user_invalid_email.errors[:email]).to include("を○○@○○.○○の形式で入力して下さい")
    end

    it 'passwordが空欄の場合バリデーションが通らない' do
      user_without_password = build(:user, password: nil)
      expect(user_without_password).to be_invalid
      expect(user_without_password.errors[:password]).to include("を入力してください")
    end

    it 'passwordが7文字以下の場合バリデーションが通らない' do
      user_short_password = build(:user, password: "a" * 7)
      expect(user_short_password).to be_invalid
      expect(user_short_password.errors[:password]).to include("は8文字以上で入力してください")
    end

    it 'passwordが76文字以上の場合バリデーションが通らない' do
      user_over_password = build(:user, password: "a" * 76)
      expect(user_over_password).to be_invalid
      expect(user_over_password.errors[:password]).to include("は75文字以内で入力してください")
    end
  end
end
