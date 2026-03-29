import importlib.util
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "scripts" / "gowid.py"
SPEC = importlib.util.spec_from_file_location("gowid_script", MODULE_PATH)
gowid = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(gowid)


class RuleSearchQueryTests(unittest.TestCase):
    def test_tokenize_rule_query_removes_command_words(self) -> None:
        self.assertEqual(gowid._tokenize_rule_query("자동규칙 검색 ExampleService"), ["exampleservice"])
        self.assertEqual(gowid._tokenize_rule_query("회의툴 규칙"), ["회의툴"])

    def test_rule_search_text_includes_requirement_answer(self) -> None:
        text = gowid._rule_search_text(
            {
                "store_pattern": "SLACK T087GTVPGVD",
                "purpose_name": "IT서비스 이용료",
                "requirement_answer": "Slack 워크스페이스",
            }
        )
        self.assertIn("slack", text)
        self.assertIn("it서비스 이용료", text)
        self.assertIn("slack 워크스페이스", text)


if __name__ == "__main__":
    unittest.main()
