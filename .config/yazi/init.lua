-- ~/.config/yazi/init.lua

-- [Tip] Full border (전체 테두리 적용)
-- Yazi v0.3 이상에서 UI 레이아웃 커스터마이징
local function setup_full_border(self, area)
	self.area = area
	
	local chunks = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({
			ui.Constraint.Ratio(1, 5), -- 부모 디렉토리 (왼쪽)
			ui.Constraint.Ratio(2, 5), -- 현재 디렉토리 (중간)
			ui.Constraint.Ratio(2, 5), -- 미리보기 (오른쪽)
		})
		:split(area)

	-- 각 패널에 테두리 적용
	return {
		self:render_parent(chunks[1]:padding(ui.Padding.x(1))),
		self:render_current(chunks[2]:padding(ui.Padding.x(1))),
		self:render_preview(chunks[3]:padding(ui.Padding.x(1))),
	}
end

-- [Tip] Show username and hostname in header
function Header:render(area)
	local chunks = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({
			ui.Constraint.Percentage(50),
			ui.Constraint.Percentage(50),
		})
		:split(area)

	local left = ui.Line {
		ui.Span(os.getenv("USER") .. "@" .. os.getenv("HOSTNAME") .. ": "),
		ui.Span(self.cwd:sub(1)), -- 현재 경로
	}

	return {
		ui.Paragraph(area, { left }),
	}
end

-- [Tip] Maximize / Hide preview pane (플러그인 로직)
-- 이 부분은 별도의 플러그인 파일로 만드는 것이 정석이나, 간단히 init.lua에 포함하거나
-- ~/.config/yazi/plugins/max-preview.yazi/init.lua 파일을 만들어야 합니다.
-- *아래 내용을 init.lua에 직접 넣으면 작동하지 않을 수 있으므로, 플러그인 설치를 권장합니다.*
-- 하지만 요청하신 '설정 파일' 형태를 위해 기본적인 상태 관리 로직을 설명합니다.
