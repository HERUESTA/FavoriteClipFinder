module LoginMacros
  def login_as(user)
    visit root_path
    click_link 'ログイン'
    fill_in 'Eメール', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログイン'
  end
end
