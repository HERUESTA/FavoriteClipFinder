import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video"
export default class extends Controller {
  static targets =  ["thumbnail", "iframe"];
  
  showVideo() {
    // ユーザーがサムネイルをクリックした時にサムネイルを非表示にする
    this.thumbnailTarget.style.display = "none";

    // iframe（動画）を表示する
    this.iframeTarget.style.display = "block";
  }
}
