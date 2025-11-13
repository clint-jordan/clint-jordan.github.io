---
title: "Monitoring Activity"
tags: [linux, rhcsa]
published: 2025-11-08T16:28:12+00:00
feature: false
draft: true
---

## Exploring jobs and processes
- All tasks are started as processes
- Common Process Management tasks include scheduling priority and sending signals
- Some processes start multiple threads, individual threads cannot be managed
- Tasks that are started from a shell can be managed as jobs
- Shell jobs can be started in the foreground or background

## Managing shell jobs
- Use `command &` to start a job in the background
- To move a job to the background
  - First, stop it by typing Ctrl-z
  - Next, type `bg` to move it to the background
  - Use `fg` to bring it back to the foreground
- Use `jobs` for a complete overview of running jobs

## Process states
- When a new process is started (forked) it is scheduled and after being
  scheduled, it will get a runnable state (R)
  - In this state it is waiting in the queue to be scheduled
- Runnable processes will get a time slice, which allows them to get a running
  state in either kernel space or user space
- Runnable processes can get preempted or rescheduled
  - In that case, they will return to a runnable state and wait in the queue for
    a new time slice
- A runnable process can be stopped (ctrl-z) and will show as TASK_STOPPED (T),
  and after being stopped it can receive another signal to resume and return to a
  runnable state
- While running, the process may have to wait
  - This is also referred to as "blocking" state, but "blocking" is not an official state in the Linux kernel
- Waiting processes can have different flags
  - TASK_INTERRUPTIBLE (S): the process is waiting for hardware request, system resource access, or a signal
  - TASK_UNINTERRUPTIBLE (D): the process is waiting but does not respond to signals 
  - TASK_KILLABLE (K): the process is waiting but may be killed 
  - TASK_REPORT_IDLE (I): used for kernel threads, this process will not count for the load average
- When a process exits, it will briefly enter the EXIT_ZOMBIE (Z) state. This is
  where it signals the parent process that it exits and all resources except for
  the PID are released.
- In the next stage the process will enter the EXIT_DEAD (X) state. In this
  state it will be reaped and all remaining processes will be cleaned up
  - When a process gets reaped, the parent process is calling the wait() system
    call to collect the exit status of the child process, after which it can be
    cleaned up
- A process becomes a Zombie when it has completed its task, but the parent
  process hasn't collected it execution status 
  - Zombies are already dead, so they can't and don't have to be killed
  - The most important disadvantage is that Zombies occupy a PID
  - To get rid of a Zombie, the parent process must collect the child execution status
    - Send SIGCHLD to the parent to ask the parent to reap the Zombie
    - Kill the parent. When the parent is killed, the Zombie becomes an orphan
      and will be adopted by the init process

## Observing process information with `ps`
- The `ps` command has two different dialects: BSD and System V
  - In BSD, options do not have a leading -
  - In System V, options do have a leading -
- Therefore `ps -L` and `ps L` are two completely different commands!
- `ps` shows an overview of current processes
- `ps aux` shows an overview of all processes
- `ps -fax` shows process forks
- `ps -fU {user}` shows all processes owned by user
- `ps -f --forest -C sshd` shows sshd and all the children
- `ps L` lists format specifiers
- `ps -eo pid,ppid,user,cmd` example of using format specifiers to get what you want

## Monitoring memory usage
- Linux places as many files as possible in cache to guarantee fast access
- For that reason, Linux memory often shows as saturated
- Swap is used as an overflow buffer of emulated RAM on disk
- The kernel moves inactive application memory to swap first
- Inactive cache memory will just be dropped
- Use `free -m` to get details about current memory usage
- More detailed memory information is in `/proc/meminfo`

### Write cache
- While writing files, a write cache (buffer) is used
- This write cache is periodically committed to disk by the `pdflush` kernel thread
- As a result, after committing a file write, it's not immediately secure
- To ensure that a file is committed to disk immediately, use the sync command

## Observing CPU load
- CPU load is checked through `uptime`

## Monitoring activity with `top`
- `top` is a dashboard that allows you to monitor current system activity
- Press `f` to show and select from available display fields
- Press `M` to filter on memory usage
- Press `W` to save new display settings
- Press `1` to show the usage stats for all CPUs

## Lab Exercise
- Use the appropriate utilities to find out if your machine performance is in
  good shape


### Solution
- Use `top`
