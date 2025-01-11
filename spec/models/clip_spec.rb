require 'rails_helper'

RSpec.describe Clip, type: :model do
  before do
    Clip.destroy_all
  end
  let!(:game_apex) { create(:game, game_id: Clip::GAME_ID[:APEX]) }
  let!(:game_gta) { create(:game, game_id: Clip::GAME_ID[:GTA]) }
  let!(:clip_oldest) { create(:clip, clip_created_at: 3.day.ago) }
  let!(:clip_middle) { create(:clip, clip_created_at: 2.day.ago) }
  let!(:clip_latest) { create(:clip, clip_created_at: 1.day.ago) }

  # ゲームIDごとに複数レコードをさl作成
  let!(:apex_clip1) { create(:clip, game_id: Clip::GAME_ID[:APEX], clip_created_at: 2.days.ago) }
  let!(:apex_clip2) { create(:clip, game_id: Clip::GAME_ID[:APEX], clip_created_at: 1.days.ago) }
  let!(:gta_clip1) { create(:clip, game_id: Clip::GAME_ID[:GTA], clip_created_at: 1.days.ago) }

  describe 'Scopes' do
    describe 'latest' do
      context '引数を指定しない場合' do
        it 'デフォルトで最新の6件を取得すること' do
          expect(Clip.latest).to match_array([ clip_latest, clip_middle, clip_oldest, apex_clip1, apex_clip2, gta_clip1 ])
        end
      end
    end
  end
end
