import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["myLibrary", "likedPlaylists"]

  connect() {
  }

  showMyLibrary(event) {
    event.preventDefault()
    this._activateTab("myLibrary")
  }

  showLikedPlaylists(event) {
    event.preventDefault()
    this._activateTab("likedPlaylists")
  }

  _activateTab(tabName) {
    // コンテンツ表示切替
    this.myLibraryTarget.classList.toggle("hidden", tabName !== "myLibrary")
    this.likedPlaylistsTarget.classList.toggle("hidden", tabName !== "likedPlaylists")

    // すべてのタブを非アクティブに戻す
    const tabs = this.element.querySelectorAll("[role='tablist'] .tab")
    tabs.forEach(tab => {
      tab.classList.remove("bg-purple-600", "text-white")
      tab.classList.add("bg-white", "text-purple-600")
    })

    // 選択タブをアクティブ（紫背景・白文字）に
    let activeTab
    if (tabName === "myLibrary") {
      activeTab = this.element.querySelector("[data-action*='showMyLibrary']")
    } else {
      activeTab = this.element.querySelector("[data-action*='showLikedPlaylists']")
    }
    activeTab.classList.remove("bg-white", "text-purple-600")
    activeTab.classList.add("bg-purple-600", "text-white")
  }
}