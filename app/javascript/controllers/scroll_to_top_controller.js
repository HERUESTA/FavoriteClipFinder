// app/javascript/controllers/scroll_to_top_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // ページネーションリンクのクリックイベントを監視
    document.querySelectorAll(".pagination a").forEach((link) => {
      link.addEventListener("click", this.scrollToTopWithDelay.bind(this));
    });
  }

  scrollToTopWithDelay(event) {
    // クリック後、少し遅延を加えて画面上部にスクロール
    setTimeout(() => {
      window.scrollTo(0, 0);
    }, 200); // 遅延時間を調整（200ミリ秒）
  }
}