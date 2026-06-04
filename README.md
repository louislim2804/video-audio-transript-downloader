# ytget — Video / Audio / Transcript Downloader
# ytget — 视频 / 音频 / 字幕 下载工具

A simple tool to download YouTube (and more) videos, audio, and transcripts on Windows.
简单易用的 Windows 下载工具，支持 YouTube 及多个平台的视频、音频和字幕。

---

## Requirements / 系统要求

- Windows 10 or Windows 11
- Internet connection (for first-time setup)
- Nothing else — setup handles everything automatically

- Windows 10 或 Windows 11
- 网络连接（首次安装需要）
- 无需其他准备，setup 会自动完成所有配置

---

## First-time Setup / 初次安装

1. Put all files in one folder — anywhere you like (e.g. `C:\ytget\`)
2. Double-click **setup.bat**
3. Wait — it downloads `yt-dlp.exe` (~20 MB) and `ffmpeg.exe` (~120 MB) automatically
4. When it says **"Setup complete!"**, you're done

1. 将所有文件放在同一个文件夹（例如 `C:\ytget\`）
2. 双击 **setup.bat**
3. 等待 — 程序会自动下载 `yt-dlp.exe`（约 20 MB）和 `ffmpeg.exe`（约 120 MB）
4. 看到 **"Setup complete!"** 即完成

> setup.bat is safe to run again anytime — it skips files already installed and can check for updates.
> setup.bat 可以随时重复运行，已安装的文件会被跳过，也可用于检查更新。

---

## Daily Use / 日常使用

Double-click **ytget.bat** — the menu appears:
双击 **ytget.bat**，菜单如下：

```
=== ytget v3 ===
  1) Custom quality video
  2) Audio only (m4a)
  3) Transcript  (en / 中文 / ja)
  4) Update yt-dlp
  q) Quit

Number or paste link(s):
```

**Quick download / 快速下载:**
Paste a YouTube link directly and press Enter — downloads best quality video automatically.
直接粘贴链接按 Enter — 自动以最佳画质下载。

**Type a number / 输入数字:** Choose a specific mode.
选择特定模式。

**Go back / 返回:** Type `b` and press Enter at any prompt.
在任何输入提示处输入 `b` 回车可返回主菜单。

**Stop a download / 停止下载:** Press `Ctrl + C`.

---

## Downloading Multiple Links / 批量下载

**Option 1 — Paste multiple links separated by spaces / 用空格分隔多个链接粘贴:**
```
Number or paste link(s): https://youtu.be/AAA https://youtu.be/BBB
```

**Option 2 — Use a .txt file / 使用 .txt 文件（每行一个链接）:**

Create a plain text file (e.g. `links.txt`), one URL per line:
创建纯文本文件（例如 `links.txt`），每行一个链接：
```
https://www.youtube.com/watch?v=AAAA
https://www.youtube.com/watch?v=BBBB
https://www.youtube.com/playlist?list=CCCC
```
Then paste the file path (or drag the file into the terminal) when prompted.
然后在提示时粘贴文件路径（或将文件拖入命令行窗口）。

**Playlists / 播放列表:** Paste the playlist URL directly — all videos download automatically.
直接粘贴播放列表链接，所有视频自动下载。

---

## Where Files Go / 文件保存位置

All downloads are saved in subfolders next to ytget.bat:
所有下载文件保存在 ytget.bat 同一文件夹内的子文件夹中：

| Downloaded content | Folder |
|---|---|
| Videos | `video download\` |
| Audio files | `audio download\` |
| Subtitle/transcript files | `transcript download\` |

Re-running a download skips files already finished (tracked in `.downloaded.txt` inside each folder).
重复运行时会跳过已下载的文件（记录在每个文件夹的 `.downloaded.txt` 中）。

---

## Transcript Notes / 字幕说明

- Downloads subtitles in: English, Traditional Chinese, Simplified Chinese, Japanese
- 下载语言：英文、繁体中文、简体中文、日文
- Saves as `.srt` files (open with any text editor or video player)
- If the video has no CC (closed captions), a message will say so — nothing to fix
- 如果视频没有 CC（字幕），程序会提示，无需操作

---

## Supported Sites / 支持的网站

This tool supports **1000+ websites** — not just YouTube.
本工具支持 **1000+ 网站**，不只是 YouTube。

Works: YouTube, YouTube Shorts, YouTube playlists, Instagram, Facebook, Twitter/X, Vimeo, SoundCloud, and many more.
支持：YouTube、YouTube Shorts、YouTube 播放列表、Instagram、Facebook、Twitter/X、Vimeo、SoundCloud 等。

Some sites (e.g. Douyin, Bilibili) require you to be logged in — they are not supported without extra setup.
部分网站（如抖音、哔哩哔哩）需要登录才能下载，暂不支持。

---

## Tips / 小贴士

- **Can't play the file on Windows?** Install [VLC media player](https://www.videolan.org/vlc/) — it plays everything.
- **无法用 Windows 默认播放器播放？** 安装 [VLC 播放器](https://www.videolan.org/vlc/)，支持所有格式。
- **Keep yt-dlp updated** (option 4 in the menu) — YouTube changes frequently and updates fix issues.
- **保持 yt-dlp 更新**（菜单选项 4），YouTube 经常变化，更新能修复问题。
- **Shorts download** the same way as regular videos — just paste the `/shorts/` URL.
- **YouTube Shorts** 下载方式与普通视频相同，直接粘贴 `/shorts/` 链接即可。
