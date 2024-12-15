  // app/javascript/controllers/scroll_to_top_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // ページネーションリンクのクリックイベントを監視
    document.querySelectorAll(".pagination a").forEach((link) => {
      link.addEventListener("click", this.scrollToTopWithDelay.bind(this));
    });
  }

  scrollToTop(event) {
      window.scrollTo(0, 0);
  };
}