#!/bin/bash
# RHF-BUYER loader (untuk pembeli)
CONFIG_URL="https://raw.githubusercontent.com/radardada/RHF-BUYER/main/config.json"

R="\e[31m"; G="\e[32m"; Y="\e[33m"; C="\e[36m"; W="\e[97m"; NC="\e[0m"

clear
echo -e "${G}RHF SYSTEM — RHF FREE / RHF VIP / RHF EVENT${NC}"
echo

CONFIG=$(curl -s "$CONFIG_URL")
if [ -z "$CONFIG" ]; then
  echo -e "${R}Gagal mengambil konfigurasi. Cek koneksi atau hubungi penjual.${NC}"
  exit 1
fi

SYS=$(echo "$CONFIG" | jq -r '.system_status')
FREE_STATUS=$(echo "$CONFIG" | jq -r '.free.status')
VIP_STATUS=$(echo "$CONFIG" | jq -r '.vip.status'")
EVENT_SRC=$(echo "$CONFIG" | jq -r '.event_source'")

if [[ "$SYS" != "on" ]]; then
  echo -e "${R}Sistem sedang dimatikan oleh admin.${NC}"
  exit 0
fi

echo -e "${Y}1) RHF FREE"
echo -e "2) RHF VIP"
echo -e "3) RHF EVENT${NC}"
read -p "Pilih (1/2/3): " M

if [[ "$M" == "1" ]]; then
  if [[ "$FREE_STATUS" == "off" ]]; then
    echo -e "${R}RHF FREE sedang dimatikan oleh admin.${NC}"
    exit 0
  fi
  echo -e "${G}RHF FREE aktif — menjalankan optimasi dasar...${NC}"
  # (contoh aksi) Anda bisa tambah fungsi legal di sini
  sleep 1
  echo -e "${C}Selesai.${NC}"
  exit 0
fi

if [[ "$M" == "2" ]]; then
  if [[ "$VIP_STATUS" == "off" ]]; then
    echo -e "${R}RHF VIP dimatikan admin.${NC}"
    exit 0
  fi
  read -p "Masukkan Kode VIP: " KODE
  EXISTS=$(echo "$CONFIG" | jq -r ".vip.codes[\"$KODE\"].expire")
  ACTIVE=$(echo "$CONFIG" | jq -r ".vip.codes[\"$KODE\"].active")

  if [[ "$EXISTS" == "null" ]] || [[ -z "$EXISTS" ]]; then
    echo -e "${R}Kode VIP tidak ditemukan.${NC}"
    exit 1
  fi
  if [[ "$ACTIVE" == "false" ]]; then
    echo -e "${R}Kode VIP dinonaktifkan admin.${NC}"
    exit 1
  fi
  # cek tanggal expire
  EXP=$(date -d "$EXISTS" +%s 2>/dev/null || echo 0)
  NOW=$(date +%s)
  if [[ $EXP -ne 0 && $NOW -gt $EXP ]]; then
    echo -e "${R}Kode VIP sudah kadaluarsa.${NC}"
    exit 1
  fi

  echo -e "${G}Kode valid — VIP aktif sampai: ${Y}$EXISTS${NC}"
  echo -e "${G}Menjalankan paket VIP premium...${NC}"
  # (contoh aksi) kamu bisa tambah fungsi premium di sini
  sleep 1
  echo -e "${C}Selesai. Terima kasih sudah membeli VIP.${NC}"
  exit 0
fi

if [[ "$M" == "3" ]]; then
  if [[ -z "$EVENT_SRC" ]] || [[ "$EVENT_SRC" == "null" ]]; then
    echo -e "${R}Tidak ada event tersedia.${NC}"
    exit 0
  fi
  echo -e "${G}=== EVENT TERBARU ===${NC}"
  curl -s "$EVENT_SRC" | tac
  exit 0
fi

echo -e "${R}Pilihan tidak dikenal.${NC}"
exit 1