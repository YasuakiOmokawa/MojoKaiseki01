//アナリティクスアカウント情報取得のためのjavascript

// jsファイル内の共通プロパティ
var accountId; // アナリティクスアカウントID
// webプロパティ .. webデータの集計単位
var webpropertyId; // webプロパティID
var webpropertyName; // webプロパティ名
// プロファイル（ビュー） .. webプロパティの閲覧可能単位
var profileId; // プロファイル（ビュー）ID
var profileName; // プロファイル（ビュー）名
var $jqObj; // jqueryオブジェクト一時格納用
var $div // DOM要素一時格納用


// セッション情報取得ボタンがクリックされたときに実行される関数
function makeApiCall() {
  queryAccounts();
}

function queryAccounts() {
  console.log('Querying Accounts.');

  // 認証されたユーザーに紐付けられた全てのアナリティクスアカウントを取得
  gapi.client.analytics.management.accounts.list().execute(handleAccounts);
}

function handleAccounts(results) {
  if (!results.code) {
    if (results && results.items && results.items.length) {

      // 最初に登録されたアナリティクスアカウントidを取得
      var firstAccountId = results.items[0].id;
      var firstAccountName = results.username;
      console.log('authorized account name is ' + firstAccountName);
      $div = $("#g_account_name");
      $jqObj = $("<p>").text("現在 " + firstAccountName + " として認証されています");
      $div.append($jqObj);

      // セレクトボックス用のラベル生成
      var $propertyLabel = $("#g_property_select_label");
      $jqObj = $("<label>").text("Webプロパティ");
      $propertyLabel.append($jqObj);
      var $profileLabel = $("#g_profile_select_label");
      $jqObj = $("<label>").text("プロファイル（ビュー）");
      $profileLabel.append($jqObj);

      // アカウントのウェブプロパティをリクエストする
      queryWebproperties(firstAccountId);

    } else {
      console.log('No accounts found for this user.')
    }
  } else {
    console.log('There was an error querying accounts: ' + results.message);
  }
}

function queryWebproperties(accountId) {
  console.log('Querying Webproperties.');

  // アカウントの全てのウェブプロパティを取得する
  gapi.client.analytics.management.webproperties.list({'accountId': accountId}).execute(handleWebproperties);
}

// 取得したウェブプロパティを操作し、プロパティ選択用のセレクトボックスを作成
function handleWebproperties(results) {
  if (!results.code) {
    if (results && results.items && results.items.length) {

      accountId = results.items[0].accountId; // ウェブプロパティ取得用に、アナリティクスアカウントidを取得
      var $propertySelect = $("#g_property_select");
      $("#g_property_select > option").remove();
      var web_idx = 0;
      web_idx = parseInt(web_idx);
      while (web_idx < results.items.length) {
        webpropertyId = results.items[web_idx].id;
        webpropertyName = results.items[web_idx].name;
        console.log('webproperty Id/Name is ' + webpropertyId + '/' + webpropertyName);
        $jqObj = $("<option>").html(webpropertyName).val(webpropertyId);
        $propertySelect.append($jqObj);
        web_idx++;
      }
      
      // セレクトボックス選択したときのイベント追加
      $propertySelect.change(function () {
        webpropertyId = $("#g_property_select").val();
        $("#g_profile_select > option").remove();
        queryProfiles(accountId, webpropertyId);
      }).change();
      
    } else {
      console.log('No webproperties found for this user.');
    }
  } else {
    console.log('There was an error querying webproperties: ' + results.message);
  }
}

function queryProfiles(accountId, webpropertyId) {
  console.log('Querying Views (Profiles).');
  // アナリティクスアカウントに紐付けられているプロパティのプロファイル情報を全て取得
  gapi.client.analytics.management.profiles.list({
      'accountId': accountId,
      'webPropertyId': webpropertyId
  }).execute(handleProfiles);
}

// 取得したプロファイル情報を操作し、プロファイルid選択用のセレクトボックスを生成する
function handleProfiles(results) {
  if (!results.code) {
    if (results && results.items && results.items.length) {

      var $profileSelect = $("#g_profile_select");
      var view_idx = 0;
      idx = parseInt(view_idx);
      while (view_idx < results.items.length) {
        profileId = results.items[view_idx].id;
        profileName = results.items[view_idx].name;
        console.log('profile id/name is ' + '/' + profileId + '/' + profileName);
        $jqObj = $("<option>").html(profileName).val(profileId);
        $profileSelect.append($jqObj);
        view_idx++;
      }

      // セレクトボックス選択したときのイベント追加
      $profileSelect.change(function () {
        profileId = $("#g_profile_select").val();
        $("#g_view_id").val(profileId);
      }).change();
      // Step 3. 実際のレポートを取得する
      // queryCoreReportingApi(firstProfileId);

    } else {
      console.log('No views (profiles) found for this user.');
    }
  } else {
    console.log('There was an error querying views (profiles): ' + results.message);
  }
}

// function queryCoreReportingApi(profileId) {
//   console.log('Querying Core Reporting API.');

//   //　アナリティクスのデータを取得
//   gapi.client.analytics.data.ga.get({
//     'ids': 'ga:' + profileId,
//     'start-date': '2012-03-03',
//     'end-date': '2012-03-03',
//     'metrics': 'ga:sessions'
//   }).execute(handleCoreReportingResults);
// }

// function handleCoreReportingResults(results) {
//   if (results.error) {
//     console.log('There was an error querying core reporting API: ' + results.message);
//   } else {
//     printResults(results);
//   }
// }

// function printResults(results) {
//   if (results.rows && results.rows.length) {
//     console.log('View (Profile) Name: ', results.profileInfo.profileName);
//     console.log('Total Sessions: ', results.rows[0][0]);
//   } else {
//     console.log('No results found');
//   }
// }
