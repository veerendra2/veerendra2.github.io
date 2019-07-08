---
layout: post
title: Ansible Cheatsheets
categories: ansible linux
comments: true
---

Yep, that's right, one more blog on cheatsheet. Because we can easily forget if we don't practice continuously. From past few months I've been working on Ansible, I just want to make some notes on what I learned and try to update this cheatsheet frequently.

I have create example playbooks in my [repo](https://github.com/veerendra2/useless-scripts/tree/master/code_snippets/ansible) to cover below topics 

Below are the things I choose to cover in this post. (_Reader expected to have prior knowledge on Ansible_)

1. Variables
   * What is variable in ansible?
   * How to define?
   * Access variable
2. Iterations
   * with_nested
   * with_subelements
   * loop
   * with_lines
3. ini and line configuration files
   * line in file (GET/SET)
   * ini (GET/SET)
4. Poll a Command
5. Jinja Templating

## 1. Variables
Variables or facts are created per hosts basis, since Ansible is designed to executes tasks on multiple servers, it maintains variables or facts per host.

For example, let's say there is a group called 'webservers' in inventory file and defined a variable inside Play


{% highlight shell %}
---
$ cat inventory.txt
[webserver]
192.168.0.10
192.168.0.11
192.168.0.12


- name: First Play
  hosts: webserver
  gather_facts: false
  vars:
    myvars: Hello World
    elements:
      - "Hydrogen"
      - "Helium"
    atomic_no: { 'hydrogen': 1, 'helium': 2 }
    atomic_weight: # Dict with YAML Syntax
      hydrogen: 1
      helium: 2
   tasks:
   - name: Run Some Tasks
     shell: echo {{ myvars }} > /tmp/test
{% endhighlight %}

All the variables that are defined in `vars` are mapped to 3 web server, since we defined `webserver` as target hosts. Ansible tracks the variables like below

<table class="tablelines">
 <tr>
  <th>Host</th><th>Variables/Facts</th>
 </tr>
 <tr>
  <td>192.168.0.10</td><td>myvars, elements, atomic_no, atomic_weight</td>
 </tr>
 <tr>
  <td>192.168.0.11</td><td>myvars, elements, atomic_no, atomic_weight</td>
 </tr>
 <tr>
  <td>192.168.0.12</td><td>myvars, elements, atomic_no, atomic_weight</td>
 </tr>
</table>

And there are some other facts that are created by Ansible automatically like hostname, IPs, default gateway ,etc. Again these are also create per hosts basis. 

### Define Variable

#### `set_fact`
 
{% highlight shell %}
---
- name: Var Example2
  hosts: localhost
  
  tasks:
  - name: Creating or setting fact
    set_fact:
      myvars: "Ghost"
{% endhighlight %}

#### With `vars`
{% highlight shell %}
---
- name: Var Example2
  hosts: localhost
  vars:
    myvars1: "Ghost"
    myvars2: "Daemon"
  
  tasks:
  - name: Creating or setting fact
    set_fact:
      myvars: "Ghost"
{% endhighlight %}

#### Pitfall
Don't try to use before the variable definition is complete like below
{% highlight shell %}
---
- name: Var Example2
  hosts: localhost
  
  tasks:
  - name: Creating or setting fact
    set_fact:
      count: 10
      add_to_count: count + 10
{% endhighlight %}
Remember, the variable `count` will only defined after the execution of task `Creating or setting fact`. The above playbook can written as
{% highlight shell %}
---
- name: Var Example2
  hosts: localhost
  
  tasks:
  - name: Creating or setting fact
    set_fact:
      count: 10
      add_to_count: 10 + 10
{% endhighlight %}

### Access one `play`'s variable/facts in another `play`
As you know, a playbook contains one or more plays, each play contains one or more tasks. Generally, in Ansible, the variables in one play with different `hosts` are not accessible directly on another play with another `hosts`. By using `hostvars`, we can access variables.
{% highlight shell %}
{% raw %}
---
- name: First Play
  hosts: webservers
  
  tasks:
  - name: Creating or setting fact
    set_fact:
      myvars: "Ghost"
 
- name: Second Play
  hosts: localhost
  
  tasks:
  - name: Accessing Fist Play's Varaible
    debug: var="This is {{ item }}'s variable ->{{hostvars[item].myvarst}}."
    with_items: "{{ groups['web_servers'] }}"
{% endraw %}
{% endhighlight %}

`groups` is in-built function to get list of hosts that are defined under `web_servers` in inventory file. So, we are iterating on `web_servers` and get host's variable called "myvars" which was defined in above play.


## 2. Iterations


<style>
.tablelines table, .tablelines td, .tablelines th {
        border: 2px solid black;
        padding: 5px;
        }
.tablelines th{
 text-align:center;
 font-weight:bold
}

.PageNavigation {
  font-size: 16px;
  display: block;
  width: auto;
  overflow: hidden;
}

.PageNavigation a {
  display: block;
  width: 80%;
  float: left;
  margin: 1em 0;
}

.PageNavigation .next {
  text-align: left;
}

</style>