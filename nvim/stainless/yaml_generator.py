from __future__ import annotations

from pathlib import Path
from typing_extensions import TypedDict


TEMPLATE = """
; ------- {language} injections -------

; top level code blocks
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "{language}")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "code" "test")
    value: (block_node
	  (block_scalar) @{highlight}
	  (#offset! @{highlight} 0 1 0 0)
    )
  )))
)

; returns
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "{language}")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "returns")
    value: (flow_node (plain_scalar
      (string_scalar) @{highlight}
    ))
  )))
)

; imports
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "{language}")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "imports" "test_imports")
    value: (block_node (block_sequence (block_sequence_item
      (flow_node (plain_scalar
        (string_scalar) @{highlight}
      ))
    )))
  )))
)

; custom arguments
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "{language}")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "arguments")
    value: (block_node (block_mapping (block_mapping_pair
      key: (flow_node) @_key_foo (#any-of? @_key_foo "definition")
      value: (block_node (block_sequence (block_sequence_item
        (flow_node
          (single_quote_scalar) @{highlight}
          (#offset! @{highlight} 0 1 0 0)
        )
      )))
    )))
  )))
)
"""


class Language(TypedDict):
    language: str
    highlight: str


LANGUAGES: list[Language] = [
    {
        'language': 'python',
        'highlight': 'python',
    },
    {
        'language': 'node',
        'highlight': 'typescript',
    },
    {
        'language': 'java',
        'highlight': 'kotlin',
    },
]


INJECTIONS_PATH = (
    Path(__file__).parent.parent / 'queries' / 'yaml' / 'injections.scm'
)


def main() -> None:
    content = [TEMPLATE.format(**language) for language in LANGUAGES]
    INJECTIONS_PATH.write_text('\n'.join(content))


if __name__ == '__main__':
    main()
