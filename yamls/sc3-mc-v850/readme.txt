
・Nios2依存部の入力ファイルを流用しているため，不要なパラメータが
　いくつか残っています
・executer_moduleがNios2依存部のままになっていますが，v850依存部の
　モジュールを置き換えて実行してください
　-v850依存部では，downloader_moduleは不要です
・icisr-convertテストは未確認です

