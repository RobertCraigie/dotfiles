
; ------- python injections -------

; top level code blocks
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "python")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "code" "test")
    value: (block_node
	  (block_scalar) @python
	  (#offset! @python 0 1 0 0)
    )
  )))
)

; returns
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "python")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "returns")
    value: (flow_node (plain_scalar
      (string_scalar) @python
    ))
  )))
)

; imports
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "python")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "imports" "test_imports")
    value: (block_node (block_sequence (block_sequence_item
      (flow_node (plain_scalar
        (string_scalar) @python
      ))
    )))
  )))
)

; custom arguments
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "python")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "arguments")
    value: (block_node (block_mapping (block_mapping_pair
      key: (flow_node) @_key_foo (#any-of? @_key_foo "definition")
      value: (block_node (block_sequence (block_sequence_item
        (flow_node
          (single_quote_scalar) @python
          (#offset! @python 0 1 0 0)
        )
      )))
    )))
  )))
)


; ------- node injections -------

; top level code blocks
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "node")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "code" "test")
    value: (block_node
	  (block_scalar) @typescript
	  (#offset! @typescript 0 1 0 0)
    )
  )))
)

; returns
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "node")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "returns")
    value: (flow_node (plain_scalar
      (string_scalar) @typescript
    ))
  )))
)

; imports
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "node")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "imports" "test_imports")
    value: (block_node (block_sequence (block_sequence_item
      (flow_node (plain_scalar
        (string_scalar) @typescript
      ))
    )))
  )))
)

; custom arguments
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "node")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "arguments")
    value: (block_node (block_mapping (block_mapping_pair
      key: (flow_node) @_key_foo (#any-of? @_key_foo "definition")
      value: (block_node (block_sequence (block_sequence_item
        (flow_node
          (single_quote_scalar) @typescript
          (#offset! @typescript 0 1 0 0)
        )
      )))
    )))
  )))
)


; ------- java injections -------

; top level code blocks
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "java")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "code" "test")
    value: (block_node
	  (block_scalar) @kotlin
	  (#offset! @kotlin 0 1 0 0)
    )
  )))
)

; returns
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "java")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "returns")
    value: (flow_node (plain_scalar
      (string_scalar) @kotlin
    ))
  )))
)

; imports
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "java")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "imports" "test_imports")
    value: (block_node (block_sequence (block_sequence_item
      (flow_node (plain_scalar
        (string_scalar) @kotlin
      ))
    )))
  )))
)

; custom arguments
(block_mapping_pair
  key: (flow_node) @_language_key (#any-of? @_language_key "java")
  value: (block_node (block_mapping (block_mapping_pair
    key: (flow_node) @_key (#any-of? @_key "arguments")
    value: (block_node (block_mapping (block_mapping_pair
      key: (flow_node) @_key_foo (#any-of? @_key_foo "definition")
      value: (block_node (block_sequence (block_sequence_item
        (flow_node
          (single_quote_scalar) @kotlin
          (#offset! @kotlin 0 1 0 0)
        )
      )))
    )))
  )))
)
