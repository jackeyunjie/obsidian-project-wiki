# Obsidian Project Wiki — 统一命令入口
# 用法：make <target>
#
# 本 Makefile 提供 Skill 仓库级别的快捷命令。
# 项目级 vault 初始化后会自带自己的 Makefile。

SHELL := /bin/bash
SKILL_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(SKILL_DIR)/scripts

.PHONY: help install check test clean

help:
	@echo "Obsidian Project Wiki — Skill 仓库命令"
	@echo ""
	@echo "  make install    — 运行安装脚本（交互式）"
	@echo "  make check      — 运行示例 vault 体检"
	@echo "  make test       — 运行所有验证测试"
	@echo "  make clean      — 清理临时文件"
	@echo ""
	@echo "项目级命令（在 vault 目录中）："
	@echo "  make -C <vault-dir> check   — 体检"
	@echo "  make -C <vault-dir> sync     — 同步到 Git"

install:
	@echo "运行安装脚本..."
	@bash $(SCRIPTS_DIR)/install.sh --help
	@echo ""
	@echo "请运行：bash $(SCRIPTS_DIR)/install.sh --project-name <name>"

check:
	@echo "运行示例 vault 体检..."
	@bash $(SCRIPTS_DIR)/check.sh $(SKILL_DIR)/examples/sample-vault

test:
	@echo "运行验证测试..."
	@echo ""
	@echo "[1/4] 测试 install.sh..."
	@bash $(SCRIPTS_DIR)/install.sh --project-name test --target /tmp/opw-test-install >/dev/null 2>&1 && echo "  ✓ install.sh 通过" || echo "  ✗ install.sh 失败"
	@echo ""
	@echo "[2/4] 测试 check.sh..."
	@bash $(SCRIPTS_DIR)/check.sh /tmp/opw-test-install >/dev/null 2>&1 && echo "  ✓ check.sh 通过" || echo "  ✗ check.sh 失败"
	@echo ""
	@echo "[3/4] 测试 sync.sh（dry-run）..."
	@cd /tmp/opw-test-install && git init >/dev/null 2>&1; bash $(SCRIPTS_DIR)/sync.sh /tmp/opw-test-install --dry-run >/dev/null 2>&1 && echo "  ✓ sync.sh 通过" || echo "  ✗ sync.sh 失败"
	@echo ""
	@echo "[4/4] 测试 update.sh..."
	@bash $(SCRIPTS_DIR)/update.sh /tmp/opw-test-install >/dev/null 2>&1 && echo "  ✓ update.sh 通过" || echo "  ✗ update.sh 失败"
	@echo ""
	@echo "测试完成！"

clean:
	@echo "清理临时文件..."
	@rm -rf /tmp/opw-test-install /tmp/opw-check-report-*.md /tmp/opw-update-prompt-*.md
	@echo "  ✓ 临时文件已清理"
