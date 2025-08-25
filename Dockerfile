# 使用 Ubuntu 22.04 作為基礎映像
FROM ubuntu:22.04

# 設定環境變數以避免互動式安裝提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新套件列表並安裝常用工具
RUN apt-get update && apt-get install -y \
    # 基本工具
    curl \
    wget \
    git \
    vim \
    nano \
    tree \
    htop \
    # 網路工具
    net-tools \
    iputils-ping \
    netcat \
    # 檔案壓縮工具
    zip \
    unzip \
    tar \
    # 系統工具
    procps \
    lsof \
    # 開發工具
    gcc \
    make \
    # 文字處理工具
    grep \
    sed \
    gawk \
    # 其他實用工具
    man-db \
    less \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 建立練習用的使用者
RUN useradd -m -s /bin/bash linuxuser && \
    echo "linuxuser:password" | chpasswd && \
    usermod -aG sudo linuxuser

# 建立練習用的目錄結構和檔案
RUN mkdir -p /home/linuxuser/practice/files && \
    mkdir -p /home/linuxuser/practice/scripts && \
    mkdir -p /home/linuxuser/practice/projects && \
    echo "歡迎來到 Linux 練習環境！" > /home/linuxuser/practice/files/welcome.txt && \
    echo "這是一個測試檔案" > /home/linuxuser/practice/files/test.txt && \
    echo "#!/bin/bash\necho 'Hello, Linux!'" > /home/linuxuser/practice/scripts/hello.sh && \
    chmod +x /home/linuxuser/practice/scripts/hello.sh && \
    chown -R linuxuser:linuxuser /home/linuxuser/practice

# 設定工作目錄
WORKDIR /home/linuxuser

# 切換到練習用的使用者
USER linuxuser

# 設定啟動時的命令
CMD ["/bin/bash"] 