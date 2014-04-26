// アナリティクスAPIの認証を行う関数。

// scopes以外の値は、各自のアプリケーションによって変えてください。
var clientId = "85989112199.apps.googleusercontent.com";
var apiKey = "AIzaSyDX7oZxMwk7O9Lh6DTO2jk1vvDAeQ3bTKo";
var scopes = "https://www.googleapis.com/auth/analytics.readonly";

// ライブラリが読み込まれたあとで、最初に呼ばれる関数
//　以下、呼び出す関数は関数名を書いた次のセクション（　ブレースで囲まれた部分　）に定義していく
function handleClientLoad() {
  // 1. APIキーをセット
  gapi.client.setApiKey(apiKey);

  // 2. ユーザ認証の確認
  window.setTimeout(checkAuth,1);
}

function checkAuth() {
  // 今のユーザーの認証状態を確認するため、グーグルアカウントサービスを呼び出す
  // handleAuthResult関数へ、以下の関数の結果を返却する
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, handleAuthResult);
}

function handleAuthResult(authResult) {
  if (authResult) {
    // ユーザーの認証が完了
    // アナリティクスアカウントの情報を読み込む
    loadAnalyticsClient();
  } else {
    // ユーザー認証が失敗
    handleUnAuthorized();
  }
}

// 認証されたユーザー
function handleAuthorized() {
  var authorizeButton = document.getElementById('authorize-button');
  var getPropertySelect = document.getElementById('g_property_select');
  var getProfileSelect = document.getElementById('g_profile_select');
  var logoutButton = document.getElementById('logout-button');

// 'セッション情報取得'ボタンを表示し、 その他を非表示
  authorizeButton.style.visibility = 'hidden';
  getPropertySelect.style.visibility = '';
  getProfileSelect.style.visibility = '';
  logoutButton.style.visibility = '';

  // 'セッション情報取得'ボタンがクリックされた場合、makeAapiCall functionを実行
  // makeApiCallButton.onclick = makeApiCall;
  makeApiCall();
}

// 認証されなかったユーザー
function handleUnAuthorized() {
  var authorizeButton = document.getElementById('authorize-button');
  var getPropertySelect = document.getElementById('g_property_select');
  var getProfileSelect = document.getElementById('g_profile_select');
  var logoutButton = document.getElementById('logout-button');

  // 'googleアカウント認証'ボタンを表示し、 その他を非表示
  authorizeButton.style.visibility = '';
  getPropertySelect.style.visibility = 'hidden';
  getProfileSelect.style.visibility = 'hidden';
  logoutButton.style.visibility = 'hidden';

  // 'googleアカウント認証'ボタンがクリックされた場合、handleAuthClick を実行
  authorizeButton.onclick = handleAuthClick;
}

function handleAuthClick(event) {
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, handleAuthResult);
  return false;
}

function loadAnalyticsClient() {
  // アナリティクスアカウントの情報を呼び出し、 その中でhandleAuthorized関数を実行する。
  gapi.client.load('analytics', 'v3', handleAuthorized);
}
