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
## 帳號相關指令
```
whoami 確認當前帳號
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
# 切換特權帳號

```
su - 模擬完整登入 含環境變數

sudo sudo（Superuser Do）命令允許以其他帳號（通常是 root）的身份執行命令。
```
## 語法相關說明
Linux 的安全模型是基於用戶和權限。每個行程都有一個相關聯的用戶，這決定了該行程可以存取哪些系統資源。當我們使用 su 或 sudo 命令時，實際上是建立一個新的 shell 行程，這個行程以目標用戶的身份運行。

1.su：當使用 su 切換用戶時，系統會啟動一個新的 shell 並且用目標用戶的身份來運行它。這個新 shell 會有目標用戶的權限。

2.sudo：sudo 命令運作不同。它會短暫地提升用戶的許可權來執行特定的命令，然後返回到原來的許可權等級。

# Linux 檔案與目錄權限
## 核心概念：權限管理
Linux 系統的檔案權限是基於使用者 (User)、群組 (Group)、其他人 (Other) 三個類別來設定的。每個類別都可以分別設定讀取 (Read)、寫入 (Write)、執行 (Execute) 三種權限。
### 使用者角色
使用者 (User, u)：檔案的擁有者。
群組 (Group, g)：檔案所屬的群組。
其他人 (Other, o)：除了使用者和群組之外的所有人。
所有類別 (All, a)：包含 u、g、o 三個類別。

### 權限符號與數值
權限可以用符號或數值來表示：

讀取 (r)：數值為 4
寫入 (w)：數值為 2
執行 (x)：數值為 1
沒有權限 (-)：數值為 0

這三個數值相加，可以組成一個三位數，分別代表 u、g、o 的權限。

範例：rwx r-x r--

使用者 (u)：rwx = 4 + 2 + 1 = 7
群組 (g)：r-x = 4 + 0 + 1 = 5
其他人 (o)：r-- = 4 + 0 + 0 = 4

權限數值為 754。

檔案與目錄的權限意義
r, w, x 在檔案和目錄上，有不同的意義：

權限符號  檔案的意義  目錄的意義
r (讀取)  可以讀取檔案內容  可以讀取目錄下的檔案名稱清單 (ls)
w (寫入)  可以修改檔案內容  可以新增、刪除、更名目錄下的檔案
x (執行)  可以執行該檔案  可以進入該目錄 (cd)

### 常用權限管理指令
- chmod (change mode)：用來改變檔案或目錄的權限。

#### 數值模式：
   - chmod 777 file1：給予所有人所有權限。
   - chmod 755 dir1：給予使用者所有權限，群組及其他人讀取和執行權限。
#### 符號模式：
   - chmod u+x file1：給予檔案擁有者執行權限。
   - chmod go-w file1：移除群組和其他人的寫入權限。
   - chmod a+rwx file1：給予所有類別讀、寫、執行權限。

- chown (change owner)：用來改變檔案或目錄的擁有者。
   - chown user1 file1：將 file1 的擁有者改為 user1。
   - chown user1:group1 file1：同時改變擁有者和所屬群組。

- chgrp (change group)：用來改變檔案或目錄的所屬群組。
   - chgrp group1 file1：將 file1 的所屬群組改為 group1。

### chmod 常用數字
777
rwx rwx rwx
所有使用者（擁有者、群組、其他人）都具備所有權限。這通常用於測試，安全性最低。

755
rwx r-x r-x
檔案擁有者擁有所有權限，群組成員和其他人則具備讀取與執行權限。這是目錄最常見的權限，允許擁有者自由管理，同時讓其他人可以進入目錄並讀取內容。

644
rw- r-- r--
檔案擁有者擁有讀取和寫入權限，群組成員和其他人則僅有讀取權限。這是檔案最常見的權限，允許擁有者修改檔案，同時讓其他人可以讀取。

700
rwx --- ---
只有檔案擁有者擁有所有權限，其他任何人都無法存取。這適用於需要高度隱私或保密性的檔案與目錄。

### 權限設定練習範例

權限應用設定
為了能夠瞭解權限的應用，我們假設需要完成下列需求：

* 建立目錄 /class
* 使用者群組關系如下
* Group: grp1
   User: user11, user12
* Group: grp2
   User: user21, user22
* 設定下列目錄權限需求
   /class/public: 所有人都可以寫入
   /class/grp1: 只有 grp1 群組可以讀寫，其它人沒有任何權限
   /class/grp2: 只有 grp2 群組可以讀寫，其它人有讀取權限

# 訊息重導
在 Linux 中，訊息重導 (Redirection) 是將命令的輸出結果或輸入來源，從預設的位置改變到其他地方的一種機制。預設情況下，指令的輸入來自鍵盤，而輸出則顯示在螢幕上。
## 訊息重導的管道
在 Linux 系統中，有三個主要的標準資料流（Standard Streams）：
1.標準輸入 (stdin, 0)：指令從這裡讀取輸入，預設來自鍵盤。
2.標準輸出 (stdout, 1)：指令將執行成功的結果寫入這裡，預設顯示在螢幕上。
3.標準錯誤 (stderr, 2)：指令將錯誤訊息寫入這裡，預設也顯示在螢幕上。

## 重導符號表

| 符號  |   類型  |              說明            | 範例  |
|------|---------|------------------------------|------|
| `>`  | 輸出重導 | 將標準輸出的結果覆蓋到指定檔案 | `ls > file.txt` (將 ls 的結果寫入 file.txt，如果檔案存在，會覆蓋其內容) |
| `>>` | 輸出重導 | 將標準輸出的結果附加到指定檔案的尾部 | `ls >> file.txt` (將 ls 的結果新增到 file.txt 的末尾) |
| `<`  | 輸入重導 | 將檔案內容作為指令的標準輸入 | `sort < file.txt` (將 file.txt 的內容作為 sort 指令的輸入) |
| `2>` | 錯誤重導 | 將標準錯誤的結果覆蓋到指定檔案 | `grep not_exist_file 2> error.log` (將錯誤訊息寫入 error.log) |
| `2>>`| 錯誤重導 | 將標準錯誤的結果附加到指定檔案的尾部 | `grep not_exist_file 2>> error.log` (將錯誤訊息新增到 error.log 的末尾) |
| `&>` | 混合重導 | 將標準輸出和標準錯誤的結果同時覆蓋到一個檔案 | `command &> log.txt` |
| `&>>`| 混合重導 | 將標準輸出和標準錯誤的結果同時附加到一個檔案 | `command &>> log.txt` |

## 範例
1.標準輸出和標準錯誤同時處理
ls -l /tmp /non_exist_dir > result.log 2> error.log
2.輸出全部丟棄
command > /dev/null 2>&1
PS: /dev/null 是一個特殊的設備檔案，所有寫入其中的資料都會被丟棄。
3.使用管道（Pipes）
管道 | 也是一種特殊的重導，它將前一個指令的標準輸出，作為後一個指令的標準輸入。
ls -l | grep file.txt


# 實作訊息重導
1.建立測試目錄並進入
```
mkdir ~/message/; cd ~/message/
```
2.複製範本練習檔案。
```
cp /etc/passwd ./sample
```

## 輸入重導

### 什麼是標準輸入（stdin）？
標準輸入（stdin） 是作業系統中的一個基本概念，它為程式提供了一個預設的資料輸入來源。你可以把它想成是程式的「耳朵」，負責接收來自外部的資訊。

stdin 的主要用途
來自鍵盤的輸入：這是最常見的用途。當你在終端機裡執行一個程式並輸入文字時，這些文字就是透過 stdin 傳送給程式。

程式間的資料傳輸：在命令列環境中，你可以使用「管道」（|）將一個程式的輸出作為另一個程式的輸入。這讓不同的程式可以串接起來，協同工作。例如，ls | grep .txt 這條指令，ls 的輸出（檔案清單）會透過 stdin 傳給 grep，讓 grep 程式只處理 .txt 檔案。

從檔案讀取：程式可以從檔案而不是鍵盤讀取資料，這在處理大量資料時特別有用。

總而言之，stdin 是一個強大的資料交換介面，它讓程式能夠從多種來源（如鍵盤、其他程式或檔案）接收數據，是程式設計和 Linux 系統管理中不可或缺的核心概念。

```
//一般取出取出 root 字串
grep root sample
root:x:0:0:root:/root:/bin/bash

//stdin 方式
grep root < sample
root:x:0:0:root:/root:/bin/bash
//我們可以看到處理結果相同，但實際上 grep 並不是直接開啟檔案進行過濾，而是透過 shell 使用 stdin (<) 將資料提供給 grep。

//管線重導 實務上應用
cat sample | grep root
root:x:0:0:root:/root:/bin/bash
```

# 輸出重導
在這個小節中，我們透過實作來瞭解程式訊息輸出的重新導向，讀者可以在此觀察到輸出的 stdout 與 stderr 的差別，並控制他們的流向。

```
//測試輸出
ls -lh sample
-rw-r--r-- 1 user1 user1 1.1K Aug 26 03:53 sample

//得知 不管哪一種輸出，都會輸出到預設的終端機

```