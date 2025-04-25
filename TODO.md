- change to json format
    - [x] create the format
    - [*] state config
    - [] display json format readable
    - [] edit modal
    - [] save edition

-- format

```json
{
    "tasks": [
        {
            "name": "task 1",
            "description": "description",
            "status": "todo",
            "priority": 1,
            "due_date": "2023-10-01",
            "tags": ["tag1", "tag2"],
            "subtasks": [
                {
                    "name": "subtask 1",
                    "status": "done"
                    "subtasks": [
                        {
                            "name": "subtask 1.1",
                            "status": "todo"
                        },
                        {
                            "name": "subtask 1.2",
                            "status": "in progress"
                        }
                    ]
                }
            ]
        }
    ]
}
```


```lua
    if line:match("%[x%]") then
      table.insert(M.tasks, vim.fn.json_encode(line))
    end
```
