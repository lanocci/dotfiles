; reference: Emacs実践入門～思考を直感的にコード化し、開発を加速する (WEB+DB PRESS plus)

(require 'cl)

;; パスを通す(http://moonstruckdrops.github.io/blog/2013/03/24/markdown-mode/)
(dolist (dir (list
              "/sbin"
              "/usr/sbin"
              "/bin"
              "/usr/bin"
              "/opt/local/bin"
              "/sw/bin"
              "/usr/local/bin"
              (expand-file-name "~/bin")
              (expand-file-name "~/.emacs.d/bin")
              ))
 (when (and (file-exists-p dir) (not (member dir exec-path)))
   (setenv "PATH" (concat dir ":" (getenv "PATH")))
   (setq exec-path (append (list dir) exec-path))))

;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)

;; Emacs 23より前のバージョンではuser-emacs-directory変数が未定義のため次の設定を追加
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

;; package.elの設定
(when (require 'package nil t)
  ;; パッケージリポジトリにMarmaladeと開発者運営のELPAを追加
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("ELPA" . "http://tromey.com/elpa/"))
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
  (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
  ;; インストールしたパッケージにロードパスを通して読み込む
  (package-initialize))

;;; いつも使うパッケージがなければ先にインストール
;;; cf. http://qiita.com/hmikisato/items/043355e1e2dd7ad8cd43

(require 'server)
(unless (server-running-p)
  (server-start))

;; インストールするパッケージのリスト
(defvar my/packages
  '(
    use-package anything helm undohist ctags undo-tree elscreen markdown-mode eruby-mode slim-mode wgrep web-mode flycheck nxml-mode auto-complete scss-mode flymake-css rinari color-moccur moccur-edit js2-mode ido-vertical-mode emoji-fontset smex ido-ubiquitous flx-ido inf-ruby yaml-mode flymake-yaml python-mode go-mode scala-mode groovy-mode terraform-mode sbt-mode ensime neotree all-the-icons wakatime-mode go-eldoc
   ))

; リストのパッケージをインストール
(let ((not-installed
       (cl-loop for x in my/packages
                when (not (package-installed-p x))
                collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
      (package-install pkg))))

;; el-getがインストールされていれば有効化、そうでなければgithubからインストール
;; (http://tarao.hatenablog.com/entry/20150221/1424518030)
(add-to-list 'load-path (locate-user-emacs-file "el-get/el-get"))
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

;; elgetでリストの内容をインストール
;; (defvar my/el-get-packages
;;   '(
;;     howm egg init-loader gtags emmet-mode py-autopep8
;;    ))
;; (el-get 'sync my/el-get-packages)


;; load-path を追加する関数を定義
;; (defun add-to-load-path (&rest paths)
;;   (let (path)
;;     (dolist (path paths paths)
;;       (let ((default-directory
;;               (expand-file-name (concat user-emacs-directory path))))
;;         (add-to-list 'load-path default-directory)
;;         (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
;;             (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
;; (add-to-load-path "elisp" "conf" "public_repos")

;; (require 'egg)				

;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
  (menu-bar-mode 0))


;; C-mにnewline-and-indentを割り当てる。
(global-set-key (kbd "C-m") 'newline-and-indent)
;; 折り返しトグルコマンド
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
;; "C-t" でウィンドウを切り替える。初期値はtranspose-chars
(define-key global-map (kbd "C-t") 'other-window)

(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "~/bin")

;;; 文字コードを指定する
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;; Mac OS Xの場合のファイル名の設定
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;; Windowsの場合のファイル名の設定
(when (eq window-system 'w32)
  (set-file-name-coding-system 'cp932)
  (setq locale-coding-system 'cp932))



;; カラム番号表示
(column-number-mode t)
;; ファイルサイズ表示
(size-indication-mode t)
;; 時計を表示（好みに応じてフォーマットを変更可能）
;; (setq display-time-day-and-date t) ; 曜日・月・日を表示
;; (setq display-time-24hr-format t) ; 24時表示
(display-time-mode t)
;; バッテリー残量を表示
(display-battery-mode t)
;; リージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
;; http://d.hatena.ne.jp/sonota88/20110224/1298557375
(defun count-lines-and-chars ()
  (if mark-active
      (format "%d lines,%d chars "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
      ;; これだとエコーエリアがチラつく
      ;;(count-lines-region (region-beginning) (region-end))
    ""))

(add-to-list 'default-mode-line-format
             '(:eval (count-lines-and-chars)))

;;; タイトルバーにファイルのフルパスを表示
(setq frame-title-format "%f")
;; 行番号を常に表示する
;; (global-linum-mode t)

;; TABの表示幅。初期値は8
(setq-default tab-width 4)
;; インデントにタブ文字を使用しない
(setq-default indent-tabs-mode nil)
;; php-modeのみタブを利用しない
;; (add-hook 'php-mode-hook
;;           '(lambda ()
;;             (setq indent-tabs-mode nil)))

;; C、C++、JAVA、PHPなどのインデント
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "bsd")))


;; リージョンの背景色を変更
;; (set-face-background 'region "darkgreen")

(when (require 'color-theme nil t)
  ;; テーマを読み込むための設定
  (color-theme-initialize)
  ;; テーマhoberに変更する
  (color-theme-hober))

(load-theme 'tango-dark)

(when (eq window-system 'ns)
  ;; asciiフォントをMenloに
  (set-face-attribute 'default nil
                      :family "Menlo"
                      :height 120)
  ;; 日本語フォントをヒラギノ明朝 Proに
  (set-fontset-font
   nil 'japanese-jisx0208
   ;; 英語名の場合
   ;; (font-spec :family "Hiragino Mincho Pro"))
   (font-spec :family "ヒラギノゴシック Pro"))
  ;; ひらがなとカタカナをモトヤシーダに
  ;; U+3000-303F	CJKの記号および句読点
  ;; U+3040-309F	ひらがな
  ;; U+30A0-30FF	カタカナ
  (set-fontset-font
   nil '(#x3040 . #x30ff)
   (font-spec :family "NfMotoyaCedar"))
  ;; フォントの横幅を調節する
  (setq face-font-rescale-alist
        '((".*Menlo.*" . 1.0)
          (".*Hiragino_Gothic_Pro.*" . 1.2)
          (".*nfmotoyacedar-bold.*" . 1.2)
          (".*nfmotoyacedar-medium.*" . 1.2)
          ("-cdac$" . 1.3))))

(when (eq system-type 'windows-nt)
  ;; asciiフォントをConsolasに
  (set-face-attribute 'default nil
                      :family "Consolas"
                      :height 120)
  ;; 日本語フォントをメイリオに
  (set-fontset-font
   nil
   'japanese-jisx0208
   (font-spec :family "メイリオ"))
  ;; フォントの横幅を調節する
  (setq face-font-rescale-alist
        '((".*Consolas.*" . 1.0)
          (".*メイリオ.*" . 1.15)
          ("-cdac$" . 1.3))))

(defface my-hl-line-face
  ;; 背景がdarkならば背景色を紺に
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; 背景がlightならば背景色を緑に
    (((class color) (background light))
     (:background "LightGoldenrodYellow" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;; paren-mode：対応する括弧を強調して表示する
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expressionは括弧内も強調表示
(setq show-paren-style 'expression)
;; フェイスを変更する
(set-face-background 'show-paren-match-face nil)
(set-face-underline-p 'show-paren-match-face "yellow")



;; バックアップファイルを作成しない
;; (setq make-backup-files nil) ; 初期値はt
;; オートセーブファイルを作らない
;; (setq auto-save-default nil) ; 初期値はt

;; バックアップファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq backup-directory-alist
;;       `((".*" . ,temporary-file-directory)))
;; オートセーブファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq auto-save-file-name-transforms
;;       `((".*" ,temporary-file-directory t)))
;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))

;; オートセーブファイル作成までの秒間隔
(setq auto-save-timeout 15)
;; オートセーブファイル作成までのタイプ間隔
(setq auto-save-interval 60)


;; ファイルが #! から始まる場合、+xを付けて保存する
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;; emacs-lisp-mode-hook用の関数を定義
(defun elisp-mode-hooks ()
  "lisp-mode-hooks"
  (when (require 'eldoc nil t)
    (setq eldoc-idle-delay 0.2)
    (setq eldoc-echo-area-use-multiline-p t)
    (turn-on-eldoc-mode)))

;; emacs-lisp-modeのフックをセット
(add-hook 'emacs-lisp-mode-hook 'elisp-mode-hooks)


;; (install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")
(when (require 'redo+ nil t)
  ;; C-' にリドゥを割り当てる
  (global-set-key (kbd "C-'") 'redo)
  ;; 日本語キーボードの場合C-. などがよいかも
  ;; (global-set-key (kbd "C-.") 'redo)
  ) 


;; (auto-install-batch "anything")
; (when (require 'anything nil t)
;   (setq
;   ;; 候補を表示するまでの時間。デフォルトは0.5
;   anything-idle-delay 0.3
;   ;; タイプして再描写するまでの時間。デフォルトは0.1
;   anything-input-idle-delay 0.2
;   ;; 候補の最大表示数。デフォルトは50
;   anything-candidate-number-limit 100
;   ;; 候補が多いときに体感速度を早くする
;   anything-quick-update t
;   ;; 候補選択ショートカットをアルファベットに
;   anything-enable-shortcuts 'alphabet)
;
;  (when (require 'anything-config nil t)
;    ;; root権限でアクションを実行するときのコマンド
;    ;; デフォルトは"su"
;    (setq anything-su-or-sudo "sudo"))
;
;  (require 'anything-match-plugin nil t)
;
;  (when (and (executable-find "cmigemo")
;             (require 'migemo nil t))
;    (require 'anything-migemo nil t))
;
;  (when (require 'anything-complete nil t)
;    ;; lispシンボルの補完候補の再検索時間
;    (anything-lisp-complete-symbol-set-timer 150))
;  (require 'anything-show-completion nil t)
;
;  (when (require 'auto-install nil t)
;    (require 'anything-auto-install nil t))
;
;  (when (require 'descbinds-anything nil t)
;    ;; describe-bindingsをAnythingに置き換える
;    (descbinds-anything-install)))
;
;(define-key global-map (kbd "M-y") 'anything-show-kill-ring)
;
;(when (require 'anything-c-moccur nil t)
;  (setq
;   ;; anything-c-moccur用 `anything-idle-delay'
;   anything-c-moccur-anything-idle-delay 0.1
;   ;; バッファの情報をハイライトする
;   anything-c-moccur-higligt-info-line-flag t
;   ;; 現在選択中の候補の位置をほかのwindowに表示する
;   anything-c-moccur-enable-auto-look-flag t
;   ;; 起動時にポイントの位置の単語を初期パターンにする
;   anything-c-moccur-enable-initial-pattern t)
;  ;; C-M-oにanything-c-moccur-occur-by-moccurを割り当てる
;  (global-set-key (kbd "C-M-o") 'anything-c-moccur-occur-by-moccur))
;
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories 
    "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default))

(when (require 'color-moccur nil t)
  ;; M-oにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スペース区切りでAND検索
  (setq moccur-split-word t)
  ;; ディレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  ;; Migemoを利用できる環境であればMigemoを使う
  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
p    (setq moccur-use-migemo t)))

(require 'moccur-edit nil t)
;; moccur-edit-finish-editと同時にファイルを保存する
;; (defadvice moccur-edit-change-file
;;   (after save-after-moccur-edit-buffer activate)
;;   (save-buffer))

;; wgrepの設定
(require 'wgrep nil t)

;; undohistの設定
(when (require 'undohist nil t)
  (undohist-initialize))

(when (require 'undo-tree nil t)
  (global-undo-tree-mode))

;; ElScreenのプレフィックスキーを変更する（初期値はC-z）
;; (setq elscreen-prefix-key (kbd "C-t"))
(when (require 'elscreen nil t)
  (elscreen-start) 
  ;; C-z C-zをタイプした場合にデフォルトのC-zを利用する
  (if window-system
      (define-key elscreen-map (kbd "C-z") 'iconify-or-deiconify-frame)
    (define-key elscreen-map (kbd "C-z") 'suspend-emacs)))

;; .gdslファイルをgroovy-modeで開く
(add-to-list 'auto-mode-alist '("\\.[sx]?gdsl?\\(\\.[a-zA-Z_]+\\)?\\'" . groovy-mode))

;; cua-modeの設定
(cua-mode t) ; cua-modeをオン
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効にする
(global-set-key (kbd "M-RET") 'cua-set-rectangle-mark)

;; HTML編集のデフォルトモードをnxml-modeにする
(add-to-list 'auto-mode-alist '("\\.[sx]?html?\\(\\.[a-zA-Z_]+\\)?\\'" . nxml-mode))
;; HTML5
(eval-after-load "rng-loc"
  '(add-to-list 'rng-schema-locating-files "~/.emacs.d/public_repos/html5-el/schemas.xml"))
;; (require 'whattf-dt)

;; </を入力すると自動的にタグを閉じる
(setq nxml-slash-auto-complete-flag t)
;; M-TABでタグを補完する
(setq nxml-bind-meta-tab-to-complete-flag t)
;; nxml-modeでauto-complete-modeを利用する
(add-to-list 'ac-modes 'nxml-mode)
;; 子要素のインデント幅を設定する。初期値は2
(setq nxml-child-indent 0)
;; 属性値のインデント幅を設定する。初期値は4
(setq nxml-attribute-indent 0)

(defun css-mode-hooks ()
  "css-mode hooks"
  ;; インデントをCスタイルにする
  (setq cssm-indent-function #'cssm-c-style-indenter)
  ;; インデント幅を2にする
  (setq cssm-indent-level 2)
  ;; インデントにタブ文字を使わない
  (setq-default indent-tabs-mode nil)
  ;; 閉じ括弧の前に改行を挿入する
  (setq cssm-newline-before-closing-bracket ))

(add-hook 'css-mode-hook 'css-mode-hooks)

(defun js-indent-hook ()
  ;; インデント幅を4にする
  (setq js-indent-level 2
        js-expr-indent-offset 2
        indent-tabs-mode nil)
  ;; switch文のcaseラベルをインデントする関数を定義する
  (defun my-js-indent-line () ; ←1●
    (interactive)
    (let* ((parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (js--proper-indentation parse-status)))
      (back-to-indentation)
      (if (looking-at "case\\s-")
          (indent-line-to (+ indentation 2))
        (js-indent-line))
      (when (> offset 0) (forward-char offset))))
  ;; caseラベルのインデント処理をセットする
  (set (make-local-variable 'indent-line-function) 'my-js-indent-line)
  ;; ここまでcaseラベルを調整する設定
  )

(add-hook 'js-mode-hook 'js-indent-hook)

;; php-modeの設定
(when (require 'php-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . php-mode))
  (setq php-search-url "http://jp.php.net/ja/")
  (setq php-manual-url "http://jp.php.net/manual/ja/"))

;; php-modeのインデント設定
(defun php-indent-hook ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  ;; (c-set-offset 'case-label '+) ; switch文のcaseラベル
  (c-set-offset 'arglist-intro '+) ; 配列の最初の要素が改行した場合
  (c-set-offset 'arglist-close 0)) ; 配列の閉じ括弧

(add-hook 'php-mode-hook 'php-indent-hook)

;; php-modeの補完を強化する
(defun php-completion-hook ()
  (when (require 'php-completion nil t)
    (php-completion-mode t)
    (define-key php-mode-map (kbd "C-o") 'phpcmp-complete)

    (when (require 'auto-complete nil t)
    (make-variable-buffer-local 'ac-sources)
    (add-to-list 'ac-sources 'ac-source-php-completion)
    (auto-complete-mode t))))

(add-hook 'php-mode-hook 'php-completion-hook)

;; perl-modeをcperl-modeのエイリアスにする
(defalias 'perl-mode 'cperl-mode)

;; cperl-modeのインデント設定
(setq cperl-indent-level 4 ; インデント幅を4にする
      cperl-continued-statement-offset 4 ; 継続する文のオフセット※
      cperl-brace-offset -4 ; ブレースのオフセット
      cperl-label-offset -4 ; labelのオフセット
      cperl-indent-parens-as-block t ; 括弧もブロックとしてインデント
      cperl-close-paren-offset -4 ; 閉じ括弧のオフセット
      cperl-tab-always-indent t ; TABをインデントにする
      cperl-highlight-variables-indiscriminately t) ; スカラを常にハイライトする

;; yaml-modeの設定
(when (require 'yaml-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))

;; perl-completionの設定
(defun perl-completion-hook ()
  (when (require 'perl-completion nil t)
    (perl-completion-mode t)
    (when (require 'auto-complete nil t)
      (auto-complete-mode t)
      (make-variable-buffer-local 'ac-sources)
      (setq ac-sources
            '(ac-source-perl-completion)))))

(add-hook  'cperl-mode-hook 'perl-completion-hook)

;; dtwをdelete-trailing-whitespaceのエイリアスにする
(defalias 'dtw 'delete-trailing-whitespace)

;; ruby-modeのインデント設定
(setq ;; ruby-indent-level 3 ; インデント幅を3に。初期値は2
      ruby-deep-indent-paren-style nil ; 改行時のインデントを調整する
      ;; ruby-mode実行時にindent-tabs-modeを設定値に変更
      ;; ruby-indent-tabs-mode t ; タブ文字を使用する。初期値はnil
      ) 

;; 括弧の自動挿入──ruby-electric
(require 'ruby-electric nil t)
;; endに対応する行のハイライト──ruby-block
(when (require 'ruby-block nil t)
  (setq ruby-block-highlight-toggle t))
;; インタラクティブRubyを利用する──inf-ruby
(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")

;; ruby-mode-hook用の関数を定義
(defun ruby-mode-hooks ()
  (inf-ruby-keys t)
  (ruby-electric-mode t)
  (ruby-block-mode t))
;; ruby-mode-hookに追加
(add-hook 'ruby-mode-hook 'ruby-mode-hooks)


;; scss-mode
(require 'scss-mode)
(add-to-list 'auto-mode-alist '("\\.scss$" . scss-mode))
 
;; インデント幅を2にする
;; コンパイルは compass watchで行うので自動コンパイルをオフ
(defun scss-custom ()
  "scss-mode-hook"
  (and
   (set (make-local-variable 'css-indent-offset) 2)
   (set (make-local-variable 'scss-compile-at-save) nil)
   )
  )
(add-hook 'scss-mode-hook
  '(lambda() (scss-custom)))


;; Makefileの種類を定義
(defvar flymake-makefile-filenames
  '("Makefile" "makefile" "GNUmakefile")
  "File names for make.")

;; Makefileがなければコマンドを直接利用するコマンドラインを生成
(defun flymake-get-make-gcc-cmdline (source base-dir)
  (let (found)
    (dolist (makefile flymake-makefile-filenames)
      (if (file-readable-p (concat base-dir "/" makefile))
          (setq found t)))
    (if found
        (list "make"
              (list "-s"
                    "-C"
                    base-dir
                    (concat "CHK_SOURCES=" source)
                    "SYNTAX_CHECK_MODE=1"
                    "check-syntax"))
      (list (if (string= (file-name-extension source) "c") "gcc" "g++")
            (list "-o"
                  "/dev/null"
                  "-fsyntax-only"
                  "-Wall"
                  source)))))

;; Flymake初期化関数の生成
(defun flymake-simple-make-gcc-init-impl
  (create-temp-f use-relative-base-dir
                 use-relative-source build-file-name get-cmdline-f)
  "Create syntax check command line for a directly checked source file.
Use CREATE-TEMP-F for creating temp copy."
  (let* ((args nil)
         (source-file-name buffer-file-name)
         (buildfile-dir (file-name-directory source-file-name)))
    (if buildfile-dir
        (let* ((temp-source-file-name
                (flymake-init-create-temp-buffer-copy create-temp-f)))
          (setq args
                (flymake-get-syntax-check-program-args
                 temp-source-file-name
                 buildfile-dir
                 use-relative-base-dir
                 use-relative-source
                 get-cmdline-f))))
    args))

;; 初期化関数を定義
(defun flymake-simple-make-gcc-init ()
  (message "%s" (flymake-simple-make-gcc-init-impl
                 'flymake-create-temp-inplace t t "Makefile"
                 'flymake-get-make-gcc-cmdline))
  (flymake-simple-make-gcc-init-impl
   'flymake-create-temp-inplace t t "Makefile"
   'flymake-get-make-gcc-cmdline))

;; 拡張子 .c, .cpp, c++などのときに上記の関数を利用する
(add-to-list 'flymake-allowed-file-name-masks
             '("\\.\\(?:c\\(?:pp\\|xx\\|\\+\\+\\)?\\|CC\\)\\'"
               flymake-simple-make-gcc-init))


;; XML用Flymakeの設定
(defun flymake-xml-init ()
  (list "xmllint" (list "--valid"
                        (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))))

;; HTML用Flymakeの設定
(defun flymake-html-init ()
  (list "tidy" (list (flymake-init-create-temp-buffer-copy
                      'flymake-create-temp-inplace))))

(add-to-list 'flymake-allowed-file-name-masks
             '("\\.html\\'" flymake-html-init))

;; tidy error pattern
(add-to-list 'flymake-err-line-patterns
'("line \\([0-9]+\\) column \\([0-9]+\\) - \\(Warning\\|Error\\): \\(.*\\)"
  nil 1 2 4))

;; JS用Flymakeの初期化関数の定義
(defun flymake-jsl-init ()
  (list "jsl" (list "-process" (flymake-init-create-temp-buffer-copy
                                'flymake-create-temp-inplace))))
;; JavaScript編集でFlymakeを起動する
(add-to-list 'flymake-allowed-file-name-masks
             '("\\.js\\'" flymake-jsl-init))

(add-to-list 'flymake-err-line-patterns
 '("^\\(.+\\)(\\([0-9]+\\)): \\(.*warning\\|SyntaxError\\): \\(.*\\)"
   1 2 nil 4))

;;; P186 Ruby
;; Ruby用Flymakeの設定
(defun flymake-ruby-init ()
  (list "ruby" (list "-c" (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-inplace))))

(add-to-list 'flymake-allowed-file-name-masks
             '("\\.rb\\'" flymake-ruby-init))

(add-to-list 'flymake-err-line-patterns
             '("\\(.*\\):(\\([0-9]+\\)): \\(.*\\)" 1 2 nil 3))

;; flymake css
(add-to-list 'load-path "~/.emacs.d/elpa/flymake-css")
(require 'flymake-css)

;; Python用Flymakeの設定
;; (install-elisp "https://raw.github.com/seanfisk/emacs/sean/src/flymake-python.el")
(when (require 'flymake-python nil t)
  ;; flake8を利用する
  (when (executable-find "flake8")
    (setq flymake-python-syntax-checker "flake8"))
  ;; pep8を利用する
  ;; (setq flymake-python-syntax-checker "pep8")
  )



;; gtags-modeのキーバインドを有効化する
(setq gtags-suggested-key-mapping t) ; 無効化する場合はコメントアウト
(require 'gtags nil t)


;; ctags.elの設定
(require 'ctags nil t)
(setq tags-revert-without-query t)
;; ctagsを呼び出すコマンドライン。パスが通っていればフルパスでなくてもよい
;; etags互換タグを利用する場合はコメントを外す
;; (setq ctags-command "ctags -e -R ")
;; anything-exuberant-ctags.elを利用しない場合はコメントアウトする
; (setq ctags-command "ctags -R --fields=\"+afikKlmnsSzt\" ")
; (global-set-key (kbd "<f5>") 'ctags-create-or-update-tags-table)

;; AnythingからTAGSを利用しやすくするコマンド作成
; (when (and (require 'anything-exuberant-ctags nil t)
;            (require 'anything-gtags nil t))
;   ;; anything-for-tags用のソースを定義
;   (setq anything-for-tags
;         (list anything-c-source-imenu
;               anything-c-source-gtags-select
;               ;; etagsを利用する場合はコメントを外す
;               ;; anything-c-source-etags-select
;               anything-c-source-exuberant-ctags-select
;               ))
; 
;   ;; anything-for-tagsコマンドを作成
;   (defun anything-for-tags ()
;     "Preconfigured `anything' for anything-for-tags."
;     (interactive)
;     (anything anything-for-tags
;               (thing-at-point 'symbol)
;               nil nil nil "*anything for tags*"))
;   
;   ;; M-tにanything-for-currentを割り当て
;   (define-key global-map (kbd "M-t") 'anything-for-tags))


;; http://blog.willnet.in/entry/20090110/1231595231
;; http://fnwiya.hatenablog.com/entry/2015/10/17/211547
(use-package ido
  :bind
  (("C-x C-r" . ido-recentf-open)
   ("C-x C-f" . ido-find-file)
   ("C-x C-d" . ido-dired)
   ("C-x b" . ido-switch-buffer)
   ("C-x C-b" . ido-switch-buffer)
   ("M-x" . smex))
  :init
  (defun ido-recentf-open ()
    "Use `ido-completing-read' to \\[find-file] a recent file"
    (interactive)
    (if (find-file (ido-completing-read "Find recent file: " recentf-list))
        (message "Opening file...")
      (message "Aborting")))
  :config
  (ido-mode 1)
  (ido-ubiquitous-mode 1)
  (setq ido-enable-flex-matching t)
  (setq ido-save-directory-list-file "~/.emacs.d/cache/ido.last")
  (ido-vertical-mode 1)
  (setq ido-vertical-define-keys 'C-n-C-p-up-and-down)
  (setq ido-max-window-height 0.75)
)
(use-package smex
  :bind
  (("M-x" . smex))
  :init
  (setq smex-save-file "~/.emacs.d/cache/.smex-items")
  :config
  (smex-initialize)
  )

;;; Rails Development

;;; Rinari
;; (require 'rinari)
;; (when (require 'rhtml-mode nil t)
;;    (add-to-list 'auto-mode-alist '("\\.html.erb\\'" . rhtml-mode)))
;; (add-hook 'rhtml-mode-hook
;;     (lambda () (rinari-launch)))

;; projectile 

;; CakePHP 1系統のemacs-cake
(when (require 'cake nil t)
  ;; emacs-cakeの標準キーバインドを利用する
  (cake-set-default-keymap)
  ;; 標準でemacs-cakeをオン
  (global-cake t))

;; CakePHP 2系統のemacs-cake
(when (require 'cake2 nil t)
  ;; emacs-cake2の標準キーバインドを利用する
  (cake2-set-default-keymap)
  ;; 標準でemacs-cake2をオフ
  (global-cake2 -1))

;; emacs-cakeを切り替えるコマンドを定義
(defun toggle-emacs-cake ()
  "emacs-cakeとemacs-cake2を切り替える"
  (interactive)
  (cond ((eq cake2 t) ; cake2がオンであれば
         (cake2 -1) ; cake2をオフにして
         (cake t)) ; cakeをオンにする
        ((eq cake t) ; cakeがオンであれば
         (cake -1) ; cakeをオフにして
         (cake2 t)) ; cake2をオンにする
        (t nil))) ; どちらもオフであれば何もしない

;; C-c tにtoggle-emacs-cakeを割り当て
;; (define-key cake-key-map (kbd "C-c t") 'toggle-emacs-cake)
;; (define-key cake2-key-map (kbd "C-c t") 'toggle-emacs-cake)

;; auto-complete, ac-cake, ac-cake2の読み込みをチェック
(when (and (require 'auto-complete nil t)
           (require 'ac-cake nil t)
           (require 'ac-cake2 nil t))
  ;; ac-cake用の関数定義
  (defun ac-cake-hook ()
    (make-variable-buffer-local 'ac-sources)
    (add-to-list 'ac-sources 'ac-source-cake)
    (add-to-list 'ac-sources 'ac-source-cake2))
  ;; php-mode-hookにac-cake用の関数を追加
  (add-hook 'php-mode-hook 'ac-cake-hook))



;; (require 'emoji)

;; ediffコントロールパネルを別フレームにしない
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; SQLサーバへ接続するためのデフォルト情報
;; (setq sql-user "root" ; デフォルトユーザ名
;;       sql-database "database_name" ;  データベース名
;;       sql-server "localhost" ; ホスト名
;;       sql-product 'mysql) ; データベースの種類



;;; Subversionフロントエンド psvn
(when (executable-find "svn")
  (setq svn-status-verbose nil)
  (autoload 'svn-status "psvn" "Run `svn status'." t))

;; GitフロントエンドEggの設定
;; (when (executable-find "git")
;;   (require 'egg nil t))


;; multi-termの設定
(when (require 'multi-term nil t)
  ;; 使用するシェルを指定
  (setq multi-term-program "/usr/local/bin/zsh"))



;; TRAMPでバックアップファイルを作成しない
(add-to-list 'backup-directory-alist
             (cons tramp-file-name-regexp nil))



;;; Emacs版manビューア（WoMan）の利用
;; キャッシュを作成
(setq woman-cache-filename "~/.emacs.d/.wmncach.el")
;; manパスを設定
(setq woman-manpath '("/usr/share/man"
                      "/usr/local/share/man"
                      "/usr/local/share/man/ja"))

;; anything-for-document用のソースを定義
; (setq anything-for-document-sources
;       (list anything-c-source-man-pages
;             anything-c-source-info-cl
;             anything-c-source-info-pages
;             anything-c-source-info-elisp
;             anything-c-source-apropos-emacs-commands
;             anything-c-source-apropos-emacs-functions
;             anything-c-source-apropos-emacs-variables))

;; anything-for-documentコマンドを作成
; (defun anything-for-document ()
;   "Preconfigured `anything' for anything-for-document."
;   (interactive)
;   (anything anything-for-document-sources
;             (thing-at-point 'symbol) nil nil nil
;             "*anything for document*"))

;; Command+dにanything-for-documentを割り当て
; (define-key global-map (kbd "s-d") 'anything-for-document)

;;; カーソル位置のファイルパスやアドレスを "C-x C-f" で開く
;; (ffap-bindings)


;; Mac の Command + f と C-x b で anything-for-files
; (define-key global-map (kbd "s-f") 'anything-for-files)
; (define-key global-map (kbd "C-x b") 'anything-for-files)
;; M-k でカレントバッファを閉じる
(define-key global-map (kbd "M-k") 'kill-this-buffer)
;; Mac の command + 3 でウィンドウを左右に分割
(define-key global-map (kbd "s-3") 'split-window-horizontally)
;; Mac の Command + 2 でウィンドウを上下に分割
(define-key global-map (kbd "s-2") 'split-window-vertically)
;; Mac の Command + 1 で現在のウィンドウ以外を閉じる
(define-key global-map (kbd "s-1") 'delete-other-windows)
;; Mac の Command + 0 で現在のウィンドウを閉じる
(define-key global-map (kbd "s-0") 'delete-window)
;; バッファを全体をインデント
(defun indent-whole-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))
;; C-<f8> でバッファ全体をインデント
(define-key global-map (kbd "C-<f8>") 'indent-whole-buffer)


;;; 改行やタブを可視化する whitespace-mode
(setq whitespace-display-mappings
      '((space-mark ?\x3000 [?\□]) ; zenkaku space
        (newline-mark 10 [8629 10]) ; newlne
        (tab-mark 9 [187 9] [92 9]) ; tab » 187
        )
      whitespace-style
      '(spaces
        ;; tabs
        trailing
        newline
        space-mark
        tab-mark
        newline-mark))
;; whitespace-modeで全角スペース文字を可視化　
(setq whitespace-space-regexp "\\(\x3000+\\)")
;; whitespace-mode をオン
(global-whitespace-mode t)
;; F5 で whitespace-mode をトグル
(define-key global-map (kbd "<f5>") 'global-whitespace-mode)


;;; Mac でファイルを開いたときに、新たなフレームを作らない
(setq ns-pop-up-frames nil)


;;; 最近閉じたバッファを復元
;; http://d.hatena.ne.jp/kitokitoki/20100608/p2
(defvar my-killed-file-name-list nil)

(defun my-push-killed-file-name-list ()
  (when (buffer-file-name)
    (push (expand-file-name (buffer-file-name)) my-killed-file-name-list)))

(defun my-pop-killed-file-name-list ()
  (interactive)
  (unless (null my-killed-file-name-list)
    (find-file (pop my-killed-file-name-list))))
;; kill-buffer-hook (バッファを消去するときのフック) に関数を追加
(add-hook 'kill-buffer-hook 'my-push-killed-file-name-list)
;; Mac の Command + z で閉じたバッファを復元する
(define-key global-map (kbd "s-z") 'my-pop-killed-file-name-list)


(setq dired-dwim-target t)

;; set "C-x ?" as help command
(global-set-key (kbd "C-x ?") 'help-command)
;; set C-h as backspace
(global-set-key (kbd "C-h") 'delete-backward-char)
;; 行番号表示
;; (global-linum-mode t)

;; markdown対応
;; markdownのコマンドのパス追加

;; windows
(when (eq window-system 'w32)
  (setq markdown-command "perl C:/strawberry/perl/bin/Markdown.pl"))

;; macOS
(when (eq system-type 'darwin)
  (setq markdown-command "multimarkdown")
  (setq markdown-open-command "marked2"))
(defun markdown-preview-file ()
  "run Marked on the current file and revert the buffer"
  (interactive)
  (shell-command
   (format "open -a \"/Applications/Marked 2.app\" %s"
       (shell-quote-argument (buffer-file-name))))
)
(global-set-key "\C-cm" 'markdown-preview-file)

;; https://github.com/emacs-jp/init-loader
;; (require 'init-loader)
;;(init-loader-load "~/.emacs.d/conf")

;; emmet-mode
;; http://qiita.com/ironsand/items/55f2ced218949efbb1fb
;; (require 'emmet-mode)
;; (add-hook 'sgml-mode-hook 'emmet-mode) ;; マークアップ言語全部で使う
;; (add-hook 'nXML-mode-hook 'emmet-mode)
;; (add-hook 'css-mode-hook  'emmet-mode) ;; CSSにも使う
;; (add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2))) ;; indent はスペース2個
;; (eval-after-load "emmet-mode"
;;   '(define-key emmet-mode-keymap (kbd "C-j") nil)) ;; C-j は newline のままにしておく
;; ; (keyboard-translate ?\C-i ?\H-i) ;;C-i と Tabの被りを回避
;; (define-key emmet-mode-keymap (kbd "H-i") 'emmet-expand-line) ;; C-i で展開

;;howm
;; (setq howm-directory (concat user-emacs-directory "howm"))
;; (setq howm-menu-lang 'ja)
;; (setq howm-file-name-format "%Y/%m/%Y-%m-%d.howm")
;; (when (require 'howm nil t)
;;   (define-key global-map (kbd "C-c ,,") 'howm-menu))
;; (defun howm-save-buffer-and-kill ()
;;   (interactive)
;;   (when (and (buffer-file-name)
;;              (string-match "\\.howm" (buffer-file-name)))
;;     (save-buffer)
;;     (kill-buffer nill)))
;; (define-key howm-mode-map (kbd "C-c C-c") 'howm-save-buffer-and-kill)
 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (wakatime-mode magit ace-jump-mode helm-ag helm-ls-git yaml-mode wgrep web-mode use-package undohist undo-tree smex slim-mode scss-mode rinari rhtml-mode nxml-mode moccur-edit markdown-mode js2-mode ido-vertical-mode ido-ubiquitous helm flymake-yaml flymake-css flycheck flx-ido eruby-mode emoji-fontset elscreen ctags auto-complete anything))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; python
;;(require 'py-autopep8)
(add-hook 'python-mode-hook
          (lambda ()
            (define-key python-mode-map "\"" 'electric-pair)
            (define-key python-mode-map "\'" 'electric-pair)
            (define-key python-mode-map "(" 'electric-pair)
            (define-key python-mode-map "[" 'electric-pair)
            (define-key python-mode-map "{" 'electric-pair)
            (define-key python-mode-map (kbd "C-c F") 'py-autopep8)          ; バッファ全体のコード整形
            (define-key python-mode-map (kbd "C-c f") 'py-autopep8-region)   ; 選択リジョン内のコード整形
            ))
;; 保存時にバッファ全体を自動整形する
(add-hook 'before-save-hook 'py-autopep8-before-save)

(defun electric-pair ()
  "Insert character pair without sournding spaces"
  (interactive)
  (let (parens-require-spaces)
    (insert-pair)))
(add-hook 'python-mode-hook '(lambda () 
     (define-key python-mode-map "\C-m" 'newline-and-indent)))
;; python pep8 auto formatting
;; http://qiita.com/fujimisakari/items/74e32eddb78dff4be585

;; golang
(add-hook 'before-save-hook 'gofmt-before-save)

(setq x-select-enable-clipboard t)



;; ensime色指定
(add-hook 'compilation-mode-hook 'ansi-color-for-comint-mode-on)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-hook 'shell-mode-hook 'sbt-mode)
(add-hook 'compilation-filter-hook
          '(lambda ()
             (let ((start-marker (make-marker))
                   (end-marker (process-mark (get-buffer-process (current-buffer)))))
               (set-marker start-marker (point-min))
                              (ansi-color-apply-on-region start-marker end-marker))))

;; OSとクリップボード共有
(setq x-select-enable-clipboard t)
(global-set-key (kbd "C-x C-b") 'buffer-menu)
(if (eq system-type 'darwin)
        (progn
          (defun copy-from-osx ()
            (shell-command-to-string "reattach-to-user-namespace pbpaste"))
          (defun paste-to-osx (text &optional push)
            (let ((process-connection-type nil))
              (let ((proc (start-process "pbcopy" "*Messages*" "reattach-to-user-namespace" "pbcopy")))
                (process-send-string proc text)
                (process-send-eof proc))))
          (setq interprogram-cut-function 'paste-to-osx)
          (setq interprogram-paste-function 'copy-from-osx)
          )
      (message "This platform is not mac")
)

(use-package ensime
  :ensure t
  :pin melpa-stable)

; neo-tree
;; 隠しファイルをデフォルトで表示
(setq neo-show-hidden-files t)

;; neotree でファイルを新規作成した後、自動的にファイルを開く
(setq neo-create-file-auto-open t)

;; delete-other-window で neotree ウィンドウを消さない
(setq neo-persist-show t)

;; キーバインドをシンプルにする
(setq neo-keymap-style 'concise)

;; neotree ウィンドウを表示する毎に current file のあるディレクトリを表示する
(setq neo-smart-open t)

;; たぶんまだ動かない https://github.com/jaypei/emacs-neotree/issues/105
(setq neo-vc-integration '(face char))

;; popwin との共存
(when neo-persist-show
  (add-hook 'popwin:before-popup-hook
            (lambda () (setq neo-persist-show nil)))
  (add-hook 'popwin:after-popup-hook
            (lambda () (setq neo-persist-show t))))

; scala mode
(add-hook 'scala-mode-hook 'my-scala-mode-hook)
(defun my-scala-mode-hook ()
  (setq scala-indent:use-javadoc-style t))

; magit
(unless (package-installed-p 'magit)
  (package-refresh-contents) (package-install 'magit))

(setenv "PATH" (concat "PATH_TO_SBT:" (getenv "PATH")))
(setenv "PATH" (concat "PATH_TO_SCALA:" (getenv "PATH")))

(unless (package-installed-p 'helm-ls-git)
  (package-refresh-contents) (package-install 'helm-ls-git))

(unless (package-installed-p 'helm-ag)
  (package-refresh-contents) (package-install 'helm-ag))

(unless (package-installed-p 'ace-jump-mode)
  (package-refresh-contents) (package-install 'ace-jump-mode))

(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

(global-set-key (kbd "C-x g") 'magit-status)

(defun forward-word+1 ()
  "forward-word で単語の先頭へ移動する"
  (interactive)
  (forward-word)
  (forward-char))

(global-set-key (kbd "M-f") 'forward-word+1)

(require 'all-the-icons)
(require 'neotree)
;; 隠しファイルをデフォルトで表示
(setq neo-show-hidden-files t)
;; cotrol + q でneotreeを起動
(global-set-key "\C-q" 'neotree-toggle)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(global-wakatime-mode)

; digdag
(add-to-list 'auto-mode-alist '("\\.dig\\'" . yaml-mode))

; Go
(setenv "GOPATH" "/Users/lanocci/go")
(add-to-list 'exec-path (expand-file-name "/Users/lanocci/go/bin"))

(use-package go-mode
  :config
  (bind-keys :map go-mode-map
         ("M-." . godef-jump)
         ("M-," . pop-tag-mark))
  (add-hook 'go-mode-hook '(lambda () (setq tab-width 2)))
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save))

(use-package go-eldoc
  :config
  (add-hook 'go-mode-hook 'go-eldoc-setup))
