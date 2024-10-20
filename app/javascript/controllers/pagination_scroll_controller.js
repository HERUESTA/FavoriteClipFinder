import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // ページロード後に指定した時間経過後、ページ上部へスクロール
      window.scrollTo({ top: 0, left: 0 });
  }
}
