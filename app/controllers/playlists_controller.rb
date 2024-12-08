# app/controllers/playlists_controller.rb
class PlaylistsController < ApplicationController
  # ユーザーが認証されていることを確認
  before_action :authenticate_user!
  # 特定のアクション前にプレイリストを設定
  before_action :set_playlist, only: [ :show, :edit, :update, :destroy ]

  # 明示的に application レイアウトを使用
  layout "application"

  def show
    # プレイリスト内の全クリップを取得
    @playlist = Playlist.find(params[:id])
    @clips = @playlist.clips.includes(:streamer).page(params[:page]).per(60)

    # 再生するクリップを特定（パラメータがなければ最初のクリップを使用）
    @clip = params[:clip_id].present? ? @clips.find_by(id: params[:clip_id]) : @clips.first
  end

  # 新しいプレイリスト作成フォームを表示
  def new
    @playlist = current_user.playlists.build
  end

  # POST /playlists
  # 新しいプレイリストを作成
  def create
    @playlist = current_user.playlists.build(playlist_params)
    if @playlist.save
      redirect_to @playlist
    else
      render :new
    end
  end

  # プレイリスト編集フォームを表示
  def edit
  end

  # プレイリストを更新
  def update
    if @playlist.update(playlist_params)
      redirect_to @playlist
    else
      render :edit
    end
  end

  # プレイリストを削除
  def destroy
    @playlist.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "#{@playlist.name}を削除しました" }
      format.html { redirect_to show_path, notice: "#{@playlist.name}を削除しました", status: :see_other }
    end
  end

  private

  # プレイリストを設定するメソッド
  def set_playlist
    # 現在のユーザーが所有するプレイリストのみを検索
    @playlist = current_user.playlists.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # プレイリストが見つからない場合はプレイリスト一覧ページにリダイレクト
    redirect_to "users/show"
  end

  # ストロングパラメータの定義
  def playlist_params
    params.require(:playlist).permit(:name)
  end
end
