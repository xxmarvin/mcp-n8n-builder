#!/bin/bash

# MacOS için mcp-n8n-builder kurulum betiği
# Bu betik, mcp-n8n-builder'ı macOS'te Claude Desktop ile çalışacak şekilde yapılandırır

# Renk tanımları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Başlık
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  MCP N8N BUILDER - MACOS KURULUMU  ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Node.js kontrolü
echo -e "${YELLOW}Node.js kontrolü yapılıyor...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js bulunamadı. Yükleniyor...${NC}"
    
    # Homebrew kontrolü
    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Homebrew bulunamadı. Lütfen önce Homebrew'i yükleyin:${NC}"
        echo -e "https://brew.sh/"
        exit 1
    fi
    
    # Node.js yükleme
    brew install node
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Node.js yüklenirken hata oluştu. Lütfen manuel olarak yükleyin.${NC}"
        exit 1
    fi
else
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}Node.js bulundu: $NODE_VERSION${NC}"
fi

# mcp-n8n-builder'ı yükleme
echo -e "\n${YELLOW}mcp-n8n-builder yükleniyor...${NC}"
npm install -g mcp-n8n-builder

if [ $? -ne 0 ]; then
    echo -e "${RED}mcp-n8n-builder yüklenirken hata oluştu.${NC}"
    exit 1
else
    echo -e "${GREEN}mcp-n8n-builder başarıyla yüklendi.${NC}"
fi

# Config dosyası oluşturma
echo -e "\n${YELLOW}Claude Desktop için yapılandırma dosyası oluşturuluyor...${NC}"

CONFIG_DIR="$HOME/.config/claude"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Config dizinini oluştur
mkdir -p "$CONFIG_DIR"

# N8N API Key sor
echo -e "${YELLOW}n8n API Key'inizi girin (veya varsayılan için boş bırakın):${NC}"
read API_KEY

if [ -z "$API_KEY" ]; then
    API_KEY="your-n8n-api-key"
    echo -e "${YELLOW}Varsayılan değer kullanılıyor: your-n8n-api-key${NC}"
    echo -e "${RED}Not: Gerçek kullanım için bu değeri değiştirmeniz gerekecek.${NC}"
fi

# n8n host sor
echo -e "${YELLOW}n8n Host URL'nizi girin (varsayılan: http://localhost:5678/api/v1):${NC}"
read HOST

if [ -z "$HOST" ]; then
    HOST="http://localhost:5678/api/v1"
    echo -e "${YELLOW}Varsayılan değer kullanılıyor: http://localhost:5678/api/v1${NC}"
fi

# Config dosyası oluştur
cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "n8n-workflow-builder": {
      "command": "bash",
      "args": [
        "-c",
        "N8N_HOST=$HOST N8N_API_KEY=$API_KEY OUTPUT_VERBOSITY=concise npx -y mcp-n8n-builder"
      ]
    }
  }
}
EOF

echo -e "${GREEN}Yapılandırma dosyası oluşturuldu: $CONFIG_FILE${NC}"

# Talimatlar
echo -e "\n${BLUE}====================================${NC}"
echo -e "${BLUE}           KURULUM TAMAMLANDI        ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""
echo -e "${GREEN}Yapılandırma dosyasını Claude Desktop'a uygulamak için:${NC}"
echo -e "1. Claude Desktop uygulamasını açın"
echo -e "2. Ayarlar'a gidin"
echo -e "3. 'Gelişmiş' sekmesine tıklayın"
echo -e "4. Aşağıdaki yapılandırma dosyasını yükleyin veya içeriğini yapıştırın:"
echo -e "   ${BLUE}$CONFIG_FILE${NC}"
echo ""
echo -e "${YELLOW}Not: n8n'in çalıştığından ve API anahtarınızın doğru olduğundan emin olun.${NC}"
echo ""
echo -e "${GREEN}Yapılandırmayı test etmek için, Claude'a aşağıdaki gibi bir komut gönderin:${NC}"
echo -e "${BLUE}n8n workflow builder ile neler yapabilirim?${NC}"
echo ""

exit 0
