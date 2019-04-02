---
title: How to filter a MySQL json array of objects
categories: mysql
tags: mysql json
---

Imagine you have a json column in your MySQL table and that column contains a list of objects. In
this example, my list will contain events that have a `name`, an `id` and other arbitrary data:

```json
[
    {
        "name": "FooEvent",
        "id": "87dd4f31-664a-4059-a3fc-6472231530e4",
        ...
    },
    {
        "name": "BarEvent",
        "id": "8ce05580-ceaf-4eb9-b5af-8ad454ca9ced",
        ...
    },
    {
        "name": "BazEvent",
        "id": "23e981cb-9e07-413b-acb0-042cd355e46d",
        ...
    }
]
```

So you have a bunch of rows in your table, each of them has an `events` column that looks something
like the example above. Now let's say you want to get the `id` for every `FooEvent`, that's not an
easy thing to do and there are multiple steps involved.

## TLDR - Just give me the answer

```sql
SELECT 
    # Find the location of the name attribute
    @path_to_name := json_unquote(json_searh(events, 'one', name, null, '$[*].name')) AS path_to_name,
    # Change $[x].name to $[x] to get the path to the actual event object
    @path_to_parent := trim(TRAILING '.name' from @path_to_name) AS path_to_parent,
    # Get the actual event object
    @event_object := json_extract(events, @path_to_parent) as event_object,
    # Finally, get the event id
    json_unquote(json_extract(@event_object, '$.id')) as event_id
FROM my_table;
```

You would get back list of results similar to:

```
87dd4f31-664a-4059-a3fc-6472231530e4
```

## Each step explained in more detail

### Step 1 - Find the location of FooEvent in the events array:

```sql
SELECT 
    json_searh(events, 'one', name, null, '$[*].name') AS path_to_name 
FROM my_table;
```

You would get back list of results similar to:

```
"$[0].name"
```

But this result is a MySQL `json string`, so we have to unquote it before we can use it:

```sql
SELECT 
    json_unquote(json_searh(events, 'one', name, null, '$[*].name')) AS path_to_name 
FROM my_table;
```

You would get back list of results similar to:

```
$[0].name
```

### Step 2 - Get the location of the parent object

```sql
SELECT 
    @path_to_name := json_unquote(json_searh(events, 'one', name, null, '$[*].name')) AS path_to_name,
    trim(TRAILING '.name' from @path_to_name) AS path_to_parent
FROM my_table;
```

You would get back list of results similar to:

```
$[0]
```

Notice that I created a MySQL user defined variable here, which makes the code much easier to read.
Otherwise you end up with a single massive unreadable line.

### Step 3 - Get the parent object

```sql
SELECT 
    @path_to_name := json_unquote(json_searh(events, 'one', name, null, '$[*].name')) AS path_to_name,
    @path_to_parent := trim(TRAILING '.name' from @path_to_name) AS path_to_parent,
    json_extract(events, @path_to_parent) as event_object
FROM my_table;
```

You would get back list of results similar to:

```
{
    "name": "FooEvent",
    "id": "87dd4f31-664a-4059-a3fc-6472231530e4",
    ...
},
```

### Step 4 - Get the id attribute from the event object

```sql
SELECT 
    @path_to_name := json_unquote(json_searh(events, 'one', name, null, '$[*].name')) AS path_to_name,
    @path_to_parent := trim(TRAILING '.name' from @path_to_name) AS path_to_parent,
    @event_object := json_extract(events, @path_to_parent) as event_object,
    json_extract(@event_object, '$.id') as event_id
FROM my_table;
```

You would get back list of results similar to:

```
"87dd4f31-664a-4059-a3fc-6472231530e4"
```

Keep in mind that this is also a `json string` so you have to unquote it:


```sql
SELECT 
    @path_to_name := json_unquote(json_searh(events, 'one', name, null, '$[*].name')) AS path_to_name,
    @path_to_parent := trim(TRAILING '.name' from @path_to_name) AS path_to_parent,
    @event_object := json_extract(events, @path_to_parent) as event_object,
    json_unquote(json_extract(@event_object, '$.id')) as event_id
FROM my_table;
```

You would get back list of results similar to:

```
87dd4f31-664a-4059-a3fc-6472231530e4
```


## Pages that helped me

* [Guide to using json_search](https://database.guide/json_search-find-the-path-to-a-string-in-a-json-document-in-mysql/)
