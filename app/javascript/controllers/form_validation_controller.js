import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "errorMessage", "lengthErrorMessage", "charCount"]; // charCount を追加

  connect() {
    console.log("FormValidationController connected");
  }

  validate(event) {
    const inputValue = this.inputTarget.value.trim(); // 入力値の前後の空白を削除

    // 入力が空白の場合
    if (inputValue === "") {
      event.preventDefault(); // フォーム送信を阻止
      this.errorMessageTarget.classList.remove("hidden"); // 必須エラーメッセージを表示
      this.lengthErrorMessageTarget.classList.add("hidden"); // 長さエラーメッセージを非表示
      this.inputTarget.classList.add("border-red-500"); // 入力枠を赤に変更
    } 
    // 入力が30文字を超える場合
    else if (inputValue.length > 30) {
      event.preventDefault(); // フォーム送信を阻止
      this.lengthErrorMessageTarget.classList.remove("hidden"); // 長さエラーメッセージを表示
      this.errorMessageTarget.classList.add("hidden"); // 必須エラーメッセージを非表示
      this.inputTarget.classList.add("border-red-500"); // 入力枠を赤に変更
    } 
    // 問題がない場合
    else {
      this.errorMessageTarget.classList.add("hidden"); // 必須エラーメッセージを非表示
      this.lengthErrorMessageTarget.classList.add("hidden"); // 長さエラーメッセージを非表示
      this.inputTarget.classList.remove("border-red-500"); // 赤枠を解除
    }
    this.countCharacters(); // 文字数をカウントして表示
  }

  countCharacters() {
    const charCount = this.inputTarget.value.length; // 現在の文字数を取得
    this.charCountTarget.textContent = `${charCount}/30`; // 文字数表示を更新
  }
}