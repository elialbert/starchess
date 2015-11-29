@strollz.factory 'boardService', [() -> 
  @remove_spaces = {
    0: [0,1,4,7,8],
    1: [0,1,7,8],
    2: [0,8],
    3: [],
    4: [0,1,7,8],
    5: [0,1,7,8],
    6: [0,1,3,4,5,7,8],
  }
  # space row/col to space id
  @space_id_lookup = {
    0: {2:10,3:16,5:27,6:34},
    1: {2:9,3:15,4:21,5:26,6:33},
    2: {1:3,2:8,3:14,4:20,5:25,6:32,7:36},
    3: {0:1,1:2,2:7,3:13,4:19,5:24,6:31,7:35,8:37},
    4: {2:6,3:12,4:18,5:23,6:30},
    5: {2:5,3:11,4:17,5:22,6:29},
    6: {2:4,6:28},
  }
  @space_rowcol_lookup = {
  }
  for row,col_hash of @space_id_lookup
    for col,space_id of @space_id_lookup[row]
      @space_rowcol_lookup[space_id] = [row,col]

  return {
    remove_spaces: @remove_spaces,
    space_id_lookup: @space_id_lookup,
    space_rowcol_lookup: @space_rowcol_lookup
    row_range: _.range(7)
    col_range: _.range(9)
  }
]   
