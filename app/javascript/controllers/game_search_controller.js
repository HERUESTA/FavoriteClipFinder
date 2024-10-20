import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.modal = document.getElementById("alert-modal"); // モーダルを取得
    this.closeButton = document.getElementById("close-modal"); // モーダルの閉じるボタンを取得

    // モーダルの閉じるボタンにクリックイベントを追加
    this.closeButton.addEventListener("click", () => {
      this.closeModal();
    });
  }

  submit(event) {
    // 入力が空かどうかをチェック
    if (this.inputTarget.value.trim() === "") {
      event.preventDefault(); // フォーム送信を防止
      this.showModal(); // モーダルを表示
    }
  }

  showModal() {
    // モーダルを表示するためのクラスを追加
    this.modal.classList.add("modal-open");
  }

  closeModal() {
    // モーダルを閉じるためのクラスを削除
    this.modal.classList.remove("modal-open");
  }
}
