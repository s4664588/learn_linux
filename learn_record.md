ls -l 顯示當前目錄清單
pwd 顯示當前路徑
cd 切換路徑
cd / 到根目錄
cd . 回上一層
mkdir 創建目錄
rmdir 移除目錄
cp 複製
head 顯示檔案前幾行
tail 顯示檔案後幾行
cat  顯示第一行到最後一行
tac  顯示最後一行到第一行
less 分頁顯示檔案
touch  可用來修改時間戳記 在權限夠時會產生空白檔案
mv  1.將目標物件移動到新的位置 2.將目標物件重新命名
rm 移除檔案
   -i 移除檔案 +刪除確認
   -f 強制移除檔案
   -r 移除子目錄及檔案
grep 字串搜尋
  -n 找到字串在第幾行
  -A 一併列出結果的前幾行
  -B 一併列出結果的後幾行
  -v 列出不符合的行
  -o 只列出符合的字串
find 
  -mtime +n 幾天前, -n 幾天內
  -mmin +n 幾分鐘前, -n 幾分鐘內
  -type f 檔案, d 目錄, -l 連結
  -name 指定標的名稱，大小寫相符
  -iname 指定標的名稱，不分大小寫
env: 顯示出目前的環境變數。這些變數僅對當前 shell 以及由它所啟動的程式有效，以系統登入來說，env 包含了系統登入後給與帳號的環境變數。
set: 列出所有變數和函式，包括環境變數和局部變數，當帳號登入以後，每個帳號自行的個人變數。
衍生 建立函數 home=test 只會在set 找尋到 要傳遞給env 要做export 的動作
```
$ export myname
$ env | grep myname
myname=bob

```
$PATH 環境變數 透過這個知道路徑來呼叫相關配置
which 指令用於找出系統將會執行的指令文件路徑。

$PATH 路徑添加可以 直接執行檔案 (可能用於自己寫的shell)
type 可以辨認 指令類別
```
# type which
which is a function
```

alias 指令別名 
  1.用途查閱目前已用別名呼叫的指令
  2.新增別名指令
unalias 刪除 指令別名

# vi/vim cli 文字編輯器

vi/vim 三種模式切換：

```
           ┌──────────────┐
           │   一般模式   │ 
           │    [ESC]     │
           └──────┬───────┘
                  │
        ┌─────────┼─────────┐
        │         │         │
        ▼         │         ▼
┌──────────┐      │    ┌──────────┐
│ 編輯模式 │◄─────┘────►│ 命令模式 │
│          │             │    :     │
└──────────┘             └──────────┘
```

模式說明：
1. 一般模式（Normal Mode）
   - 預設模式，可進行游標移動、複製、貼上、刪除等操作
   - 按 [ESC] 鍵回到此模式

2. 編輯模式（Insert Mode） 
   - 可輸入文字內容
   - 從一般模式按 i, a, o 等鍵進入
   - 按 [ESC] 回到一般模式

3. 命令模式（Command Mode）
   - 可執行存檔、離開、搜尋等指令
   - 從一般模式按 : 進入
   - 執行指令後自動回到一般模式

常用切換鍵：
- 進入編輯模式：i（當前位置）, a（下一個字元）, o（新行）
- 進入命令模式：:（指令模式）, /（搜尋模式）
- 回到一般模式：[ESC]
- 存檔離開：:wq 或 :x
- 強制離開不存檔：:q!

## 一般模式（Normal Mode）
在一般模式中，我們可以對文件上的游標進行控制。

### 游標移動
| 功能 | 按鍵 |
|------|------|
| 游標往上 | [k] |
| 游標往下 | [j] |
| 游標往左 | [h] |
| 游標往右 | [l] |
| 游標移到第 1 行 | 1G |
| 游標移到第 5 行 | 5G |
| 游標移到第 n 行 | nG (n 為數字) |
| 游標移到最後行 | G |
| 游標移到行首 | ^ |
| 游標移到行尾 | $ |

### 文件操作
| 功能 | 按鍵 |
|------|------|
| 複製 | yy |
| 複製 2 行 | 2yy |
| 複製 n 行 | nyy (n 為數字) |
| 在下一行貼上 | p (小寫英文) |
| 在上一行貼上 | P (大寫英文) |
| 剪下一個字元 | x |
| 剪下 2 個字元 | 2x |
| 剪下 n 個字元 | nx (n 為數字) |
| 刪除一整行 | dd |
| 刪除二行 | 2dd |
| 刪除 n 行 | ndd (n 為數字) |

## 指令模式（Command Mode）
指令模式通常是在一般模式中，直接輸入以 : 為開頭就會進入指令操作。

常用的指令如下所示：

| 功能 | 按鍵 |
|------|------|
| 存檔 | :w |
| 離開 | :q |
| 存檔後離開 | :wq |
| 不存檔離開 | :q! |
| 強制存檔 | :w! (需要有相關權限) |
| 尋找字串 | /{word} ({word} 代表要找的字串) |

## 編輯模式（Insert Mode）
在編輯模式裡，鍵盤上輸入的字符都會反應到檔案的本文中，也就是開始進行文件的編輯。使用下列的方式，可以從一般模式中進入編輯模式。

常用進入編輯模式的方法如下所示：

| 功能 | 按鍵 |
|------|------|
| 在目前位置開始編輯 | i |
| 在游標所在的下一字元開始編輯 | a |
| 在目前所在行下方新增新的一行後開始編輯 | o |
| 在目前所在行上方新增新的一行後開始編輯 | O |

在編輯模式中，如要回到一般模式，可以按下 [ESC]。

## 留意事項
vi 啟動時，會在文件所在位置產生一個暫時性的交換檔案，這個交換檔案會在 vi 關閉時自行刪除，如果沒有進行正確的關閉方式，那麼這個交換檔就會被留下來，當您再次開啟該檔案時可能會出現警告的訊息。

# 群組與帳號相關檔案

/etc/passwd 文字檔 可用文字編輯器開啟 查詢

##  說明 可對/etc/passwd
1  登入帳號，也就是登入系統時所輸入的帳號，在整個系統中帳號不可重複
2  使用者密碼，現在使用 x 表示，已不使用
3  記載著該帳號的使用者編號（User ID, UID），該編號在整個系統中不可重複
4  記載著該帳號的主要群組 ID，群組 ID 在 /etc/group 中會有所定義
5  該帳號的稱呼、匿名等，也可以設定為空白
6  該帳號的家目錄所在位置，預設都會放置在 /home/ 目錄中
7  該帳號登入時，要使用哪一個操作環境，預設是使用 BASH 操作環境

/etc/shadow 檔案是一用來保存密碼的檔案

##  說明 可對/etc/passwd
1  帳號，與 /etc/passwd 檔案第 1 個欄位相批配
2  使用 SHA-512 演算法加密過的密碼
3  上次密碼變更日期，從 1970-01-01 開始計算
4  密碼自修改後，多久內不可以再修改
5  密碼多久後，一定要修改
6  密碼到期前幾天要提出警告
7  密碼到期後，經過幾天後停用該帳號
8  帳號失效日期，從 1970-01-01 開始計算
9  保留給未來使用

/etc/group 存放著群組資訊

##  說明
1  群組名稱
2  群組密碼，現已不用
3  群組 ID，(Group ID, GID)
4  群組成員，每一個成員使用 , 相隔

其它參考檔案
在 Enterprise Linux 中開立帳號時，相關指定會參照帳號組態檔案進行相關的設定，如下：
/etc/login.defs

## 說明
參數  用途
MAIL_DIR  帳號建立時，該帳號的 mail 檔案存放位置
PASS_MAX_DAYS  密碼有效期限最大值
PASS_MIN_DAYS  密碼有效期限最小值
PASS_WARN_AGE  密碼到期前幾天發出警示
UID_MIN  建立一般帳號時，可使用的最小 User ID（UID）
UID_MAX  建立一般帳號時，可使用的最大 User ID（UID）
GID_MIN  建立一般群組時，可使用的最小 Group ID（GID）
GID_MAX  建立一般群組時，可使用的最大 Group ID（GID）
ENCRYPT_METHOD  密碼加密方式

/etc/skel/ 帳號開啟時，會為該帳號建立家目錄,這個目錄中可以放置預先指定好的使用者相關組態設定（使用者環境變數）或是檔案（如公用使用條款）。

# 帳號管理 

## PS:記得轉換為root 身分
id 指令說明
### 帳號名稱
root：這是帳號名稱。
### 使用者 ID 與主要群組
uid=0(root)：這是 User ID (UID)，0 是該帳號的唯一識別碼。括號內的 root 是對應的帳號名稱。

gid=0(root)：這是 Group ID (GID)，0 是該帳號的主要群組 ID。括號內的 root 是主要群組的名稱。每個帳號都必須有一個主要群組。
###　次要群組
groups=0(root)：這是該帳號所屬的所有次要群組。在這個例子中，root 帳號同時也屬於 root 這個群組，作為其唯一的次要群組。一個帳號可以屬於多個次要群組，這些群組 ID 會在這裡以逗號分隔列出。

```
root# id root
uid=0(root) gid=0(root) groups=0(root)

```

# 練習
## 建立帳號
1.確認帳號不存在
```
root# id user1
id: ‘user1’: no such user
```
2.建立使用者
```
root# useradd user1
```
3.確認要建立的帳號資訊
```
root# id user1
uid=1000(user1) gid=1000(user1) groups=1000(user1)
```

### PS 家目錄建立 useradd 不一定是預設的
後續需要用到家目錄功能 要補
```
//建置資料夾
mkdir /home/user1
//設置目錄擁有者  
chown user1:user1 /home/user1
//設定目錄權限
chmod 700 /home/user1
```
#### 另一個辦法
```
adduser  
```
#### 差異點
useradd 是一個底層的工具程式：它只會執行最基本的動作，用來建立使用者帳號。你必須手動指定所有選項，例如建立家目錄或設定密碼。

adduser 是一個高階、互動式的腳本：它是一個包裝在 useradd 外層的腳本，會以更友善的方式引導你完成所有步驟。它會自動建立家目錄、複製預設設定檔，並提示你設定密碼。

功能	useradd	adduser
類型	底層工具程式	高階互動式腳本
可用性	所有 Linux 發行版	主要在 Debian/Ubuntu
易用性	較困難（需加參數）	簡單（有互動提示）
家目錄	預設不建立	預設會建立
密碼	預設不設定	會提示你設定
用途	腳本、自動化、精確控制	一般用途、系統管理新手

# 修改帳號資訊

```
//停用帳號
root# usermod -L user1
```

```
//起用帳號
root# usermod -U user1
```

```
//停用啟用 帳號觀察 指令
root# passwd -S user1|
//停用狀態
user1 L 08/20/2025 0 99999 7 -1
//啟用狀態
user1 P 08/22/2025 0 99999 7 -1

//查看 /ect/shadow
帳號停用（usermod -L）：
usermod -L 的機制是在加密密碼前加上一個驚嘆號 !。這個驚嘆號會讓密碼變成無效，因此使用者無法登入。

root# cat /etc/shadow | grep user1
user1:!$6$.......:19600:0:99999:7:::
注意：密碼欄位開頭多了一個 !。

帳號啟用（usermod -U）：
usermod -U 則是移除這個驚嘆號，讓加密密碼恢復有效。
root# cat /etc/shadow | grep user1
user1:$6$.......:19600:0:99999:7:::

群組搬移
usermod -g {群組名稱} {使用者名稱}

實作
//主要群組變更
root@1a71f8091101:/home# usermod -g user1 user1
root@1a71f8091101:/home# id user1
uid=1001(user1) gid=1001(user1) groups=1001(user1)

//次要群組變更
root@1a71f8091101:/home# usermod -G user2 user1
root@1a71f8091101:/home# id user1

uid=1001(user1) gid=1001(user1) groups=1001(user1),1002(user2)
```

# 設定密碼

## 章節注意點

1.一般使用者只能修改自己的密碼
2.root 帳號可以修改自己和其它帳號的密碼
3.一般使用者修改密碼時如果不符密碼原則，則會修改失敗
4.root 帳號修改密碼時如果不符密碼原則，仍會修改成功

```
修改 root 自己的密碼
root# passwd root
Changing password for user root.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.

修改 user1 自己的密碼
//這邊要轉成非root 帳號
su - {使用者名稱}
# passwd user1
Changing password for user user1.
New password: <-這裡的輸入不會有任何字元顯示
BAD PASSWORD: The password is shorter than 8 characters
Retype new password: <-這裡的輸入不會有任何字元顯示
passwd: all authentication tokens updated successfully.
```

## 密碼有效期限
```
//列出密碼
root# chage -l user1
Last password change                                    : Aug 22, 2025
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7

//設定密碼更新期限
root# chage -M 90 user1
root#:/home/user1# chage -l user1
Last password change                                    : Aug 22, 2025
Password expires                                        : Nov 20, 2025
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 90
Number of days of warning before password expires       : 7
```

# 帳號刪除相關
```
刪除指令有兩種
1.userdel
2.deluser

想要連同家目錄刪除都要添加參數
1.userdel -r [使用者名稱]
2.deluser --remove-home [使用者名稱]
```

# 群組管理
PS 需要升級到root權限

```
//創建群組
root# groupadd grp1
//可以用grep 確認
root# grep grp1 /etc/group
//賦予群組 方式
useradd -g grp1 user2 //創建帳號 並賦予主要群組
gpasswd -a user2 grp1 // 將已存在的帳號 新增進次要群組

//拔除群組
gpasswd -d user1 grp1

//刪除群組 ps 注意不能有帳號設定為主要群組
groupdel grp1

```