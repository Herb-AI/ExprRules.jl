using ExprRules
using Debugger

grammar = @grammar begin
	Real = 1 | 2 
	Real = Real + Real
	end

node = RuleNode(3, [RuleNode(2), RuleNode(3, [RuleNode(1), RuleNode(2)])])

_next_state!(node, grammar, 3)