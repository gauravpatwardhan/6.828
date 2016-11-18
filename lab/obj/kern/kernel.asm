
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 40 11 00       	mov    $0x114000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 40 11 f0       	mov    $0xf0114000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 33 00 00 00       	call   f0100071 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/kclock.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 08             	sub    $0x8,%esp
f0100046:	8b 45 08             	mov    0x8(%ebp),%eax
//	cprintf("entering test_backtrace %d\n", x);
	if (x > 0)
f0100049:	85 c0                	test   %eax,%eax
f010004b:	7e 11                	jle    f010005e <test_backtrace+0x1e>
		test_backtrace(x-1);
f010004d:	83 ec 0c             	sub    $0xc,%esp
f0100050:	83 e8 01             	sub    $0x1,%eax
f0100053:	50                   	push   %eax
f0100054:	e8 e7 ff ff ff       	call   f0100040 <test_backtrace>
f0100059:	83 c4 10             	add    $0x10,%esp
f010005c:	eb 11                	jmp    f010006f <test_backtrace+0x2f>
	else
		mon_backtrace(0, 0, 0);
f010005e:	83 ec 04             	sub    $0x4,%esp
f0100061:	6a 00                	push   $0x0
f0100063:	6a 00                	push   $0x0
f0100065:	6a 00                	push   $0x0
f0100067:	e8 e1 06 00 00       	call   f010074d <mon_backtrace>
f010006c:	83 c4 10             	add    $0x10,%esp
//	cprintf("leaving test_backtrace %d\n", x);
}
f010006f:	c9                   	leave  
f0100070:	c3                   	ret    

f0100071 <i386_init>:

void
i386_init(void)
{
f0100071:	55                   	push   %ebp
f0100072:	89 e5                	mov    %esp,%ebp
f0100074:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100077:	b8 70 69 11 f0       	mov    $0xf0116970,%eax
f010007c:	2d 00 63 11 f0       	sub    $0xf0116300,%eax
f0100081:	50                   	push   %eax
f0100082:	6a 00                	push   $0x0
f0100084:	68 00 63 11 f0       	push   $0xf0116300
f0100089:	e8 fb 30 00 00       	call   f0103189 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010008e:	e8 88 04 00 00       	call   f010051b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100093:	83 c4 08             	add    $0x8,%esp
f0100096:	68 ac 1a 00 00       	push   $0x1aac
f010009b:	68 20 36 10 f0       	push   $0xf0103620
f01000a0:	e8 2b 26 00 00       	call   f01026d0 <cprintf>
	// Test the stack backtrace function (lab 1 only)
//	test_backtrace(5);

	// Lab 2 memory initialization functions
//	cprintf("Entering mem_init function\n");
	mem_init();
f01000a5:	e8 9c 0f 00 00       	call   f0101046 <mem_init>
f01000aa:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ad:	83 ec 0c             	sub    $0xc,%esp
f01000b0:	6a 00                	push   $0x0
f01000b2:	e8 64 07 00 00       	call   f010081b <monitor>
f01000b7:	83 c4 10             	add    $0x10,%esp
f01000ba:	eb f1                	jmp    f01000ad <i386_init+0x3c>

f01000bc <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000bc:	55                   	push   %ebp
f01000bd:	89 e5                	mov    %esp,%ebp
f01000bf:	56                   	push   %esi
f01000c0:	53                   	push   %ebx
f01000c1:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000c4:	83 3d 60 69 11 f0 00 	cmpl   $0x0,0xf0116960
f01000cb:	75 37                	jne    f0100104 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000cd:	89 35 60 69 11 f0    	mov    %esi,0xf0116960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000d3:	fa                   	cli    
f01000d4:	fc                   	cld    

	va_start(ap, fmt);
f01000d5:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d8:	83 ec 04             	sub    $0x4,%esp
f01000db:	ff 75 0c             	pushl  0xc(%ebp)
f01000de:	ff 75 08             	pushl  0x8(%ebp)
f01000e1:	68 3b 36 10 f0       	push   $0xf010363b
f01000e6:	e8 e5 25 00 00       	call   f01026d0 <cprintf>
	vcprintf(fmt, ap);
f01000eb:	83 c4 08             	add    $0x8,%esp
f01000ee:	53                   	push   %ebx
f01000ef:	56                   	push   %esi
f01000f0:	e8 b5 25 00 00       	call   f01026aa <vcprintf>
	cprintf("\n");
f01000f5:	c7 04 24 8c 45 10 f0 	movl   $0xf010458c,(%esp)
f01000fc:	e8 cf 25 00 00       	call   f01026d0 <cprintf>
	va_end(ap);
f0100101:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100104:	83 ec 0c             	sub    $0xc,%esp
f0100107:	6a 00                	push   $0x0
f0100109:	e8 0d 07 00 00       	call   f010081b <monitor>
f010010e:	83 c4 10             	add    $0x10,%esp
f0100111:	eb f1                	jmp    f0100104 <_panic+0x48>

f0100113 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100113:	55                   	push   %ebp
f0100114:	89 e5                	mov    %esp,%ebp
f0100116:	53                   	push   %ebx
f0100117:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010011a:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010011d:	ff 75 0c             	pushl  0xc(%ebp)
f0100120:	ff 75 08             	pushl  0x8(%ebp)
f0100123:	68 53 36 10 f0       	push   $0xf0103653
f0100128:	e8 a3 25 00 00       	call   f01026d0 <cprintf>
	vcprintf(fmt, ap);
f010012d:	83 c4 08             	add    $0x8,%esp
f0100130:	53                   	push   %ebx
f0100131:	ff 75 10             	pushl  0x10(%ebp)
f0100134:	e8 71 25 00 00       	call   f01026aa <vcprintf>
	cprintf("\n");
f0100139:	c7 04 24 8c 45 10 f0 	movl   $0xf010458c,(%esp)
f0100140:	e8 8b 25 00 00       	call   f01026d0 <cprintf>
	va_end(ap);
}
f0100145:	83 c4 10             	add    $0x10,%esp
f0100148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010014b:	c9                   	leave  
f010014c:	c3                   	ret    

f010014d <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010014d:	55                   	push   %ebp
f010014e:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100150:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100155:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100156:	a8 01                	test   $0x1,%al
f0100158:	74 0b                	je     f0100165 <serial_proc_data+0x18>
f010015a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010015f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100160:	0f b6 c0             	movzbl %al,%eax
f0100163:	eb 05                	jmp    f010016a <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100165:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010016a:	5d                   	pop    %ebp
f010016b:	c3                   	ret    

f010016c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010016c:	55                   	push   %ebp
f010016d:	89 e5                	mov    %esp,%ebp
f010016f:	53                   	push   %ebx
f0100170:	83 ec 04             	sub    $0x4,%esp
f0100173:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100175:	eb 2b                	jmp    f01001a2 <cons_intr+0x36>
		if (c == 0)
f0100177:	85 c0                	test   %eax,%eax
f0100179:	74 27                	je     f01001a2 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010017b:	8b 0d 24 65 11 f0    	mov    0xf0116524,%ecx
f0100181:	8d 51 01             	lea    0x1(%ecx),%edx
f0100184:	89 15 24 65 11 f0    	mov    %edx,0xf0116524
f010018a:	88 81 20 63 11 f0    	mov    %al,-0xfee9ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100190:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100196:	75 0a                	jne    f01001a2 <cons_intr+0x36>
			cons.wpos = 0;
f0100198:	c7 05 24 65 11 f0 00 	movl   $0x0,0xf0116524
f010019f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001a2:	ff d3                	call   *%ebx
f01001a4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a7:	75 ce                	jne    f0100177 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001a9:	83 c4 04             	add    $0x4,%esp
f01001ac:	5b                   	pop    %ebx
f01001ad:	5d                   	pop    %ebp
f01001ae:	c3                   	ret    

f01001af <kbd_proc_data>:
f01001af:	ba 64 00 00 00       	mov    $0x64,%edx
f01001b4:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001b5:	a8 01                	test   $0x1,%al
f01001b7:	0f 84 f0 00 00 00    	je     f01002ad <kbd_proc_data+0xfe>
f01001bd:	ba 60 00 00 00       	mov    $0x60,%edx
f01001c2:	ec                   	in     (%dx),%al
f01001c3:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001c5:	3c e0                	cmp    $0xe0,%al
f01001c7:	75 0d                	jne    f01001d6 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001c9:	83 0d 00 63 11 f0 40 	orl    $0x40,0xf0116300
		return 0;
f01001d0:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001d5:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001d6:	55                   	push   %ebp
f01001d7:	89 e5                	mov    %esp,%ebp
f01001d9:	53                   	push   %ebx
f01001da:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001dd:	84 c0                	test   %al,%al
f01001df:	79 36                	jns    f0100217 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001e1:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f01001e7:	89 cb                	mov    %ecx,%ebx
f01001e9:	83 e3 40             	and    $0x40,%ebx
f01001ec:	83 e0 7f             	and    $0x7f,%eax
f01001ef:	85 db                	test   %ebx,%ebx
f01001f1:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001f4:	0f b6 d2             	movzbl %dl,%edx
f01001f7:	0f b6 82 c0 37 10 f0 	movzbl -0xfefc840(%edx),%eax
f01001fe:	83 c8 40             	or     $0x40,%eax
f0100201:	0f b6 c0             	movzbl %al,%eax
f0100204:	f7 d0                	not    %eax
f0100206:	21 c8                	and    %ecx,%eax
f0100208:	a3 00 63 11 f0       	mov    %eax,0xf0116300
		return 0;
f010020d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100212:	e9 9e 00 00 00       	jmp    f01002b5 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100217:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f010021d:	f6 c1 40             	test   $0x40,%cl
f0100220:	74 0e                	je     f0100230 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100222:	83 c8 80             	or     $0xffffff80,%eax
f0100225:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100227:	83 e1 bf             	and    $0xffffffbf,%ecx
f010022a:	89 0d 00 63 11 f0    	mov    %ecx,0xf0116300
	}

	shift |= shiftcode[data];
f0100230:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100233:	0f b6 82 c0 37 10 f0 	movzbl -0xfefc840(%edx),%eax
f010023a:	0b 05 00 63 11 f0    	or     0xf0116300,%eax
f0100240:	0f b6 8a c0 36 10 f0 	movzbl -0xfefc940(%edx),%ecx
f0100247:	31 c8                	xor    %ecx,%eax
f0100249:	a3 00 63 11 f0       	mov    %eax,0xf0116300

	c = charcode[shift & (CTL | SHIFT)][data];
f010024e:	89 c1                	mov    %eax,%ecx
f0100250:	83 e1 03             	and    $0x3,%ecx
f0100253:	8b 0c 8d a0 36 10 f0 	mov    -0xfefc960(,%ecx,4),%ecx
f010025a:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100261:	a8 08                	test   $0x8,%al
f0100263:	74 1b                	je     f0100280 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100265:	89 da                	mov    %ebx,%edx
f0100267:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010026a:	83 f9 19             	cmp    $0x19,%ecx
f010026d:	77 05                	ja     f0100274 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010026f:	83 eb 20             	sub    $0x20,%ebx
f0100272:	eb 0c                	jmp    f0100280 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100274:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100277:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010027a:	83 fa 19             	cmp    $0x19,%edx
f010027d:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100280:	f7 d0                	not    %eax
f0100282:	a8 06                	test   $0x6,%al
f0100284:	75 2d                	jne    f01002b3 <kbd_proc_data+0x104>
f0100286:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010028c:	75 25                	jne    f01002b3 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010028e:	83 ec 0c             	sub    $0xc,%esp
f0100291:	68 6d 36 10 f0       	push   $0xf010366d
f0100296:	e8 35 24 00 00       	call   f01026d0 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010029b:	ba 92 00 00 00       	mov    $0x92,%edx
f01002a0:	b8 03 00 00 00       	mov    $0x3,%eax
f01002a5:	ee                   	out    %al,(%dx)
f01002a6:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002a9:	89 d8                	mov    %ebx,%eax
f01002ab:	eb 08                	jmp    f01002b5 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002b2:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b3:	89 d8                	mov    %ebx,%eax
}
f01002b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002b8:	c9                   	leave  
f01002b9:	c3                   	ret    

f01002ba <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ba:	55                   	push   %ebp
f01002bb:	89 e5                	mov    %esp,%ebp
f01002bd:	57                   	push   %edi
f01002be:	56                   	push   %esi
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 1c             	sub    $0x1c,%esp
f01002c3:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002c5:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ca:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002cf:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d4:	eb 09                	jmp    f01002df <cons_putc+0x25>
f01002d6:	89 ca                	mov    %ecx,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	ec                   	in     (%dx),%al
f01002da:	ec                   	in     (%dx),%al
f01002db:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002dc:	83 c3 01             	add    $0x1,%ebx
f01002df:	89 f2                	mov    %esi,%edx
f01002e1:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002e2:	a8 20                	test   $0x20,%al
f01002e4:	75 08                	jne    f01002ee <cons_putc+0x34>
f01002e6:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002ec:	7e e8                	jle    f01002d6 <cons_putc+0x1c>
f01002ee:	89 f8                	mov    %edi,%eax
f01002f0:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002f8:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002f9:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002fe:	be 79 03 00 00       	mov    $0x379,%esi
f0100303:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100308:	eb 09                	jmp    f0100313 <cons_putc+0x59>
f010030a:	89 ca                	mov    %ecx,%edx
f010030c:	ec                   	in     (%dx),%al
f010030d:	ec                   	in     (%dx),%al
f010030e:	ec                   	in     (%dx),%al
f010030f:	ec                   	in     (%dx),%al
f0100310:	83 c3 01             	add    $0x1,%ebx
f0100313:	89 f2                	mov    %esi,%edx
f0100315:	ec                   	in     (%dx),%al
f0100316:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010031c:	7f 04                	jg     f0100322 <cons_putc+0x68>
f010031e:	84 c0                	test   %al,%al
f0100320:	79 e8                	jns    f010030a <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100322:	ba 78 03 00 00       	mov    $0x378,%edx
f0100327:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010032b:	ee                   	out    %al,(%dx)
f010032c:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100331:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100336:	ee                   	out    %al,(%dx)
f0100337:	b8 08 00 00 00       	mov    $0x8,%eax
f010033c:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010033d:	89 fa                	mov    %edi,%edx
f010033f:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100345:	89 f8                	mov    %edi,%eax
f0100347:	80 cc 07             	or     $0x7,%ah
f010034a:	85 d2                	test   %edx,%edx
f010034c:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010034f:	89 f8                	mov    %edi,%eax
f0100351:	0f b6 c0             	movzbl %al,%eax
f0100354:	83 f8 09             	cmp    $0x9,%eax
f0100357:	74 74                	je     f01003cd <cons_putc+0x113>
f0100359:	83 f8 09             	cmp    $0x9,%eax
f010035c:	7f 0a                	jg     f0100368 <cons_putc+0xae>
f010035e:	83 f8 08             	cmp    $0x8,%eax
f0100361:	74 14                	je     f0100377 <cons_putc+0xbd>
f0100363:	e9 99 00 00 00       	jmp    f0100401 <cons_putc+0x147>
f0100368:	83 f8 0a             	cmp    $0xa,%eax
f010036b:	74 3a                	je     f01003a7 <cons_putc+0xed>
f010036d:	83 f8 0d             	cmp    $0xd,%eax
f0100370:	74 3d                	je     f01003af <cons_putc+0xf5>
f0100372:	e9 8a 00 00 00       	jmp    f0100401 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100377:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f010037e:	66 85 c0             	test   %ax,%ax
f0100381:	0f 84 e6 00 00 00    	je     f010046d <cons_putc+0x1b3>
			crt_pos--;
f0100387:	83 e8 01             	sub    $0x1,%eax
f010038a:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100390:	0f b7 c0             	movzwl %ax,%eax
f0100393:	66 81 e7 00 ff       	and    $0xff00,%di
f0100398:	83 cf 20             	or     $0x20,%edi
f010039b:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f01003a1:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003a5:	eb 78                	jmp    f010041f <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003a7:	66 83 05 28 65 11 f0 	addw   $0x50,0xf0116528
f01003ae:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003af:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f01003b6:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003bc:	c1 e8 16             	shr    $0x16,%eax
f01003bf:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c2:	c1 e0 04             	shl    $0x4,%eax
f01003c5:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
f01003cb:	eb 52                	jmp    f010041f <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003cd:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d2:	e8 e3 fe ff ff       	call   f01002ba <cons_putc>
		cons_putc(' ');
f01003d7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003dc:	e8 d9 fe ff ff       	call   f01002ba <cons_putc>
		cons_putc(' ');
f01003e1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e6:	e8 cf fe ff ff       	call   f01002ba <cons_putc>
		cons_putc(' ');
f01003eb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f0:	e8 c5 fe ff ff       	call   f01002ba <cons_putc>
		cons_putc(' ');
f01003f5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fa:	e8 bb fe ff ff       	call   f01002ba <cons_putc>
f01003ff:	eb 1e                	jmp    f010041f <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100401:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f0100408:	8d 50 01             	lea    0x1(%eax),%edx
f010040b:	66 89 15 28 65 11 f0 	mov    %dx,0xf0116528
f0100412:	0f b7 c0             	movzwl %ax,%eax
f0100415:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f010041b:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010041f:	66 81 3d 28 65 11 f0 	cmpw   $0x7cf,0xf0116528
f0100426:	cf 07 
f0100428:	76 43                	jbe    f010046d <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010042a:	a1 2c 65 11 f0       	mov    0xf011652c,%eax
f010042f:	83 ec 04             	sub    $0x4,%esp
f0100432:	68 00 0f 00 00       	push   $0xf00
f0100437:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010043d:	52                   	push   %edx
f010043e:	50                   	push   %eax
f010043f:	e8 92 2d 00 00       	call   f01031d6 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100444:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f010044a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100450:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100456:	83 c4 10             	add    $0x10,%esp
f0100459:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010045e:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100461:	39 d0                	cmp    %edx,%eax
f0100463:	75 f4                	jne    f0100459 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100465:	66 83 2d 28 65 11 f0 	subw   $0x50,0xf0116528
f010046c:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010046d:	8b 0d 30 65 11 f0    	mov    0xf0116530,%ecx
f0100473:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100478:	89 ca                	mov    %ecx,%edx
f010047a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010047b:	0f b7 1d 28 65 11 f0 	movzwl 0xf0116528,%ebx
f0100482:	8d 71 01             	lea    0x1(%ecx),%esi
f0100485:	89 d8                	mov    %ebx,%eax
f0100487:	66 c1 e8 08          	shr    $0x8,%ax
f010048b:	89 f2                	mov    %esi,%edx
f010048d:	ee                   	out    %al,(%dx)
f010048e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100493:	89 ca                	mov    %ecx,%edx
f0100495:	ee                   	out    %al,(%dx)
f0100496:	89 d8                	mov    %ebx,%eax
f0100498:	89 f2                	mov    %esi,%edx
f010049a:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010049b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010049e:	5b                   	pop    %ebx
f010049f:	5e                   	pop    %esi
f01004a0:	5f                   	pop    %edi
f01004a1:	5d                   	pop    %ebp
f01004a2:	c3                   	ret    

f01004a3 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004a3:	80 3d 34 65 11 f0 00 	cmpb   $0x0,0xf0116534
f01004aa:	74 11                	je     f01004bd <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004ac:	55                   	push   %ebp
f01004ad:	89 e5                	mov    %esp,%ebp
f01004af:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004b2:	b8 4d 01 10 f0       	mov    $0xf010014d,%eax
f01004b7:	e8 b0 fc ff ff       	call   f010016c <cons_intr>
}
f01004bc:	c9                   	leave  
f01004bd:	f3 c3                	repz ret 

f01004bf <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004bf:	55                   	push   %ebp
f01004c0:	89 e5                	mov    %esp,%ebp
f01004c2:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c5:	b8 af 01 10 f0       	mov    $0xf01001af,%eax
f01004ca:	e8 9d fc ff ff       	call   f010016c <cons_intr>
}
f01004cf:	c9                   	leave  
f01004d0:	c3                   	ret    

f01004d1 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004d1:	55                   	push   %ebp
f01004d2:	89 e5                	mov    %esp,%ebp
f01004d4:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004d7:	e8 c7 ff ff ff       	call   f01004a3 <serial_intr>
	kbd_intr();
f01004dc:	e8 de ff ff ff       	call   f01004bf <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004e1:	a1 20 65 11 f0       	mov    0xf0116520,%eax
f01004e6:	3b 05 24 65 11 f0    	cmp    0xf0116524,%eax
f01004ec:	74 26                	je     f0100514 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004ee:	8d 50 01             	lea    0x1(%eax),%edx
f01004f1:	89 15 20 65 11 f0    	mov    %edx,0xf0116520
f01004f7:	0f b6 88 20 63 11 f0 	movzbl -0xfee9ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004fe:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100500:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100506:	75 11                	jne    f0100519 <cons_getc+0x48>
			cons.rpos = 0;
f0100508:	c7 05 20 65 11 f0 00 	movl   $0x0,0xf0116520
f010050f:	00 00 00 
f0100512:	eb 05                	jmp    f0100519 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100514:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100519:	c9                   	leave  
f010051a:	c3                   	ret    

f010051b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010051b:	55                   	push   %ebp
f010051c:	89 e5                	mov    %esp,%ebp
f010051e:	57                   	push   %edi
f010051f:	56                   	push   %esi
f0100520:	53                   	push   %ebx
f0100521:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100524:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010052b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100532:	5a a5 
	if (*cp != 0xA55A) {
f0100534:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010053b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010053f:	74 11                	je     f0100552 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100541:	c7 05 30 65 11 f0 b4 	movl   $0x3b4,0xf0116530
f0100548:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010054b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100550:	eb 16                	jmp    f0100568 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100552:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100559:	c7 05 30 65 11 f0 d4 	movl   $0x3d4,0xf0116530
f0100560:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100563:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100568:	8b 3d 30 65 11 f0    	mov    0xf0116530,%edi
f010056e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100573:	89 fa                	mov    %edi,%edx
f0100575:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100576:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100579:	89 da                	mov    %ebx,%edx
f010057b:	ec                   	in     (%dx),%al
f010057c:	0f b6 c8             	movzbl %al,%ecx
f010057f:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100582:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100587:	89 fa                	mov    %edi,%edx
f0100589:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058a:	89 da                	mov    %ebx,%edx
f010058c:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010058d:	89 35 2c 65 11 f0    	mov    %esi,0xf011652c
	crt_pos = pos;
f0100593:	0f b6 c0             	movzbl %al,%eax
f0100596:	09 c8                	or     %ecx,%eax
f0100598:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059e:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a8:	89 f2                	mov    %esi,%edx
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005bb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005c0:	89 da                	mov    %ebx,%edx
f01005c2:	ee                   	out    %al,(%dx)
f01005c3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005cd:	ee                   	out    %al,(%dx)
f01005ce:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005d3:	b8 03 00 00 00       	mov    $0x3,%eax
f01005d8:	ee                   	out    %al,(%dx)
f01005d9:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005de:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e3:	ee                   	out    %al,(%dx)
f01005e4:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01005ee:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ef:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005f4:	ec                   	in     (%dx),%al
f01005f5:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005f7:	3c ff                	cmp    $0xff,%al
f01005f9:	0f 95 05 34 65 11 f0 	setne  0xf0116534
f0100600:	89 f2                	mov    %esi,%edx
f0100602:	ec                   	in     (%dx),%al
f0100603:	89 da                	mov    %ebx,%edx
f0100605:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100606:	80 f9 ff             	cmp    $0xff,%cl
f0100609:	75 10                	jne    f010061b <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f010060b:	83 ec 0c             	sub    $0xc,%esp
f010060e:	68 79 36 10 f0       	push   $0xf0103679
f0100613:	e8 b8 20 00 00       	call   f01026d0 <cprintf>
f0100618:	83 c4 10             	add    $0x10,%esp
}
f010061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010061e:	5b                   	pop    %ebx
f010061f:	5e                   	pop    %esi
f0100620:	5f                   	pop    %edi
f0100621:	5d                   	pop    %ebp
f0100622:	c3                   	ret    

f0100623 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100623:	55                   	push   %ebp
f0100624:	89 e5                	mov    %esp,%ebp
f0100626:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100629:	8b 45 08             	mov    0x8(%ebp),%eax
f010062c:	e8 89 fc ff ff       	call   f01002ba <cons_putc>
}
f0100631:	c9                   	leave  
f0100632:	c3                   	ret    

f0100633 <getchar>:

int
getchar(void)
{
f0100633:	55                   	push   %ebp
f0100634:	89 e5                	mov    %esp,%ebp
f0100636:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100639:	e8 93 fe ff ff       	call   f01004d1 <cons_getc>
f010063e:	85 c0                	test   %eax,%eax
f0100640:	74 f7                	je     f0100639 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100642:	c9                   	leave  
f0100643:	c3                   	ret    

f0100644 <iscons>:

int
iscons(int fdnum)
{
f0100644:	55                   	push   %ebp
f0100645:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100647:	b8 01 00 00 00       	mov    $0x1,%eax
f010064c:	5d                   	pop    %ebp
f010064d:	c3                   	ret    

f010064e <mon_help>:



int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010064e:	55                   	push   %ebp
f010064f:	89 e5                	mov    %esp,%ebp
f0100651:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100654:	68 c0 38 10 f0       	push   $0xf01038c0
f0100659:	68 de 38 10 f0       	push   $0xf01038de
f010065e:	68 e3 38 10 f0       	push   $0xf01038e3
f0100663:	e8 68 20 00 00       	call   f01026d0 <cprintf>
f0100668:	83 c4 0c             	add    $0xc,%esp
f010066b:	68 98 39 10 f0       	push   $0xf0103998
f0100670:	68 ec 38 10 f0       	push   $0xf01038ec
f0100675:	68 e3 38 10 f0       	push   $0xf01038e3
f010067a:	e8 51 20 00 00       	call   f01026d0 <cprintf>
f010067f:	83 c4 0c             	add    $0xc,%esp
f0100682:	68 f5 38 10 f0       	push   $0xf01038f5
f0100687:	68 0c 39 10 f0       	push   $0xf010390c
f010068c:	68 e3 38 10 f0       	push   $0xf01038e3
f0100691:	e8 3a 20 00 00       	call   f01026d0 <cprintf>
	return 0;
}
f0100696:	b8 00 00 00 00       	mov    $0x0,%eax
f010069b:	c9                   	leave  
f010069c:	c3                   	ret    

f010069d <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010069d:	55                   	push   %ebp
f010069e:	89 e5                	mov    %esp,%ebp
f01006a0:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006a3:	68 16 39 10 f0       	push   $0xf0103916
f01006a8:	e8 23 20 00 00       	call   f01026d0 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ad:	83 c4 08             	add    $0x8,%esp
f01006b0:	68 0c 00 10 00       	push   $0x10000c
f01006b5:	68 c0 39 10 f0       	push   $0xf01039c0
f01006ba:	e8 11 20 00 00       	call   f01026d0 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006bf:	83 c4 0c             	add    $0xc,%esp
f01006c2:	68 0c 00 10 00       	push   $0x10000c
f01006c7:	68 0c 00 10 f0       	push   $0xf010000c
f01006cc:	68 e8 39 10 f0       	push   $0xf01039e8
f01006d1:	e8 fa 1f 00 00       	call   f01026d0 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006d6:	83 c4 0c             	add    $0xc,%esp
f01006d9:	68 11 36 10 00       	push   $0x103611
f01006de:	68 11 36 10 f0       	push   $0xf0103611
f01006e3:	68 0c 3a 10 f0       	push   $0xf0103a0c
f01006e8:	e8 e3 1f 00 00       	call   f01026d0 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ed:	83 c4 0c             	add    $0xc,%esp
f01006f0:	68 00 63 11 00       	push   $0x116300
f01006f5:	68 00 63 11 f0       	push   $0xf0116300
f01006fa:	68 30 3a 10 f0       	push   $0xf0103a30
f01006ff:	e8 cc 1f 00 00       	call   f01026d0 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100704:	83 c4 0c             	add    $0xc,%esp
f0100707:	68 70 69 11 00       	push   $0x116970
f010070c:	68 70 69 11 f0       	push   $0xf0116970
f0100711:	68 54 3a 10 f0       	push   $0xf0103a54
f0100716:	e8 b5 1f 00 00       	call   f01026d0 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010071b:	b8 6f 6d 11 f0       	mov    $0xf0116d6f,%eax
f0100720:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100725:	83 c4 08             	add    $0x8,%esp
f0100728:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010072d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100733:	85 c0                	test   %eax,%eax
f0100735:	0f 48 c2             	cmovs  %edx,%eax
f0100738:	c1 f8 0a             	sar    $0xa,%eax
f010073b:	50                   	push   %eax
f010073c:	68 78 3a 10 f0       	push   $0xf0103a78
f0100741:	e8 8a 1f 00 00       	call   f01026d0 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100746:	b8 00 00 00 00       	mov    $0x0,%eax
f010074b:	c9                   	leave  
f010074c:	c3                   	ret    

f010074d <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074d:	55                   	push   %ebp
f010074e:	89 e5                	mov    %esp,%ebp
f0100750:	57                   	push   %edi
f0100751:	56                   	push   %esi
f0100752:	53                   	push   %ebx
f0100753:	83 ec 48             	sub    $0x48,%esp
	// Your code here.
	
	//basic stack backtrace code
	cprintf("Stack backtrace:\n");
f0100756:	68 2f 39 10 f0       	push   $0xf010392f
f010075b:	e8 70 1f 00 00       	call   f01026d0 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100760:	89 eb                	mov    %ebp,%ebx
	uintptr_t ebp_current_local = read_ebp();
	uintptr_t eip_current_local = 0;
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};
f0100762:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100769:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100770:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100777:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010077e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
f0100785:	83 c4 0c             	add    $0xc,%esp
f0100788:	6a 18                	push   $0x18
f010078a:	6a 00                	push   $0x0
f010078c:	8d 45 bc             	lea    -0x44(%ebp),%eax
f010078f:	50                   	push   %eax
f0100790:	e8 f4 29 00 00       	call   f0103189 <memset>
	while (ebp_current_local != 0){
f0100795:	83 c4 10             	add    $0x10,%esp
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f0100798:	8d 7d bc             	lea    -0x44(%ebp),%edi
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f010079b:	eb 6d                	jmp    f010080a <mon_backtrace+0xbd>
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
f010079d:	8b 73 04             	mov    0x4(%ebx),%esi
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007a0:	b8 00 00 00 00       	mov    $0x0,%eax
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
f01007a5:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01007a9:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007ad:	83 c0 01             	add    $0x1,%eax
f01007b0:	83 f8 05             	cmp    $0x5,%eax
f01007b3:	75 f0                	jne    f01007a5 <mon_backtrace+0x58>
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
f01007b5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007b8:	ff 75 e0             	pushl  -0x20(%ebp)
f01007bb:	ff 75 dc             	pushl  -0x24(%ebp)
f01007be:	ff 75 d8             	pushl  -0x28(%ebp)
f01007c1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007c4:	56                   	push   %esi
f01007c5:	53                   	push   %ebx
f01007c6:	68 a4 3a 10 f0       	push   $0xf0103aa4
f01007cb:	e8 00 1f 00 00       	call   f01026d0 <cprintf>
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f01007d0:	83 c4 18             	add    $0x18,%esp
f01007d3:	57                   	push   %edi
f01007d4:	56                   	push   %esi
f01007d5:	e8 00 20 00 00       	call   f01027da <debuginfo_eip>
f01007da:	83 c4 10             	add    $0x10,%esp
f01007dd:	85 c0                	test   %eax,%eax
f01007df:	75 20                	jne    f0100801 <mon_backtrace+0xb4>
				cprintf("        %s:%d: %.*s+%d\n", eipinfo.eip_file, eipinfo.eip_line, 
f01007e1:	83 ec 08             	sub    $0x8,%esp
f01007e4:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007e7:	56                   	push   %esi
f01007e8:	ff 75 c4             	pushl  -0x3c(%ebp)
f01007eb:	ff 75 c8             	pushl  -0x38(%ebp)
f01007ee:	ff 75 c0             	pushl  -0x40(%ebp)
f01007f1:	ff 75 bc             	pushl  -0x44(%ebp)
f01007f4:	68 41 39 10 f0       	push   $0xf0103941
f01007f9:	e8 d2 1e 00 00       	call   f01026d0 <cprintf>
f01007fe:	83 c4 20             	add    $0x20,%esp
						eipinfo.eip_fn_namelen, eipinfo.eip_fn_name, eip_current_local-eipinfo.eip_fn_addr);

		}
		// point the ebp to the next ebp using the current ebp value pushed on stack	
		ebp_current_local = *(uintptr_t *)(ebp_current_local);
f0100801:	8b 1b                	mov    (%ebx),%ebx
f0100803:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f010080a:	85 db                	test   %ebx,%ebx
f010080c:	75 8f                	jne    f010079d <mon_backtrace+0x50>
		for ( i = 0; i < MAX_ARGS_PASSED; i++){
			args_arr[0] = 0;
		}
	}
	return 0;
}
f010080e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100813:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100816:	5b                   	pop    %ebx
f0100817:	5e                   	pop    %esi
f0100818:	5f                   	pop    %edi
f0100819:	5d                   	pop    %ebp
f010081a:	c3                   	ret    

f010081b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010081b:	55                   	push   %ebp
f010081c:	89 e5                	mov    %esp,%ebp
f010081e:	57                   	push   %edi
f010081f:	56                   	push   %esi
f0100820:	53                   	push   %ebx
f0100821:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100824:	68 d8 3a 10 f0       	push   $0xf0103ad8
f0100829:	e8 a2 1e 00 00       	call   f01026d0 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010082e:	c7 04 24 fc 3a 10 f0 	movl   $0xf0103afc,(%esp)
f0100835:	e8 96 1e 00 00       	call   f01026d0 <cprintf>
f010083a:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010083d:	83 ec 0c             	sub    $0xc,%esp
f0100840:	68 59 39 10 f0       	push   $0xf0103959
f0100845:	e8 e8 26 00 00       	call   f0102f32 <readline>
f010084a:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010084c:	83 c4 10             	add    $0x10,%esp
f010084f:	85 c0                	test   %eax,%eax
f0100851:	74 ea                	je     f010083d <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100853:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010085a:	be 00 00 00 00       	mov    $0x0,%esi
f010085f:	eb 0a                	jmp    f010086b <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100861:	c6 03 00             	movb   $0x0,(%ebx)
f0100864:	89 f7                	mov    %esi,%edi
f0100866:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100869:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010086b:	0f b6 03             	movzbl (%ebx),%eax
f010086e:	84 c0                	test   %al,%al
f0100870:	74 63                	je     f01008d5 <monitor+0xba>
f0100872:	83 ec 08             	sub    $0x8,%esp
f0100875:	0f be c0             	movsbl %al,%eax
f0100878:	50                   	push   %eax
f0100879:	68 5d 39 10 f0       	push   $0xf010395d
f010087e:	e8 c9 28 00 00       	call   f010314c <strchr>
f0100883:	83 c4 10             	add    $0x10,%esp
f0100886:	85 c0                	test   %eax,%eax
f0100888:	75 d7                	jne    f0100861 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010088a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010088d:	74 46                	je     f01008d5 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010088f:	83 fe 0f             	cmp    $0xf,%esi
f0100892:	75 14                	jne    f01008a8 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100894:	83 ec 08             	sub    $0x8,%esp
f0100897:	6a 10                	push   $0x10
f0100899:	68 62 39 10 f0       	push   $0xf0103962
f010089e:	e8 2d 1e 00 00       	call   f01026d0 <cprintf>
f01008a3:	83 c4 10             	add    $0x10,%esp
f01008a6:	eb 95                	jmp    f010083d <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008a8:	8d 7e 01             	lea    0x1(%esi),%edi
f01008ab:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008af:	eb 03                	jmp    f01008b4 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008b1:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008b4:	0f b6 03             	movzbl (%ebx),%eax
f01008b7:	84 c0                	test   %al,%al
f01008b9:	74 ae                	je     f0100869 <monitor+0x4e>
f01008bb:	83 ec 08             	sub    $0x8,%esp
f01008be:	0f be c0             	movsbl %al,%eax
f01008c1:	50                   	push   %eax
f01008c2:	68 5d 39 10 f0       	push   $0xf010395d
f01008c7:	e8 80 28 00 00       	call   f010314c <strchr>
f01008cc:	83 c4 10             	add    $0x10,%esp
f01008cf:	85 c0                	test   %eax,%eax
f01008d1:	74 de                	je     f01008b1 <monitor+0x96>
f01008d3:	eb 94                	jmp    f0100869 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008d5:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008dc:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008dd:	85 f6                	test   %esi,%esi
f01008df:	0f 84 58 ff ff ff    	je     f010083d <monitor+0x22>
f01008e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ea:	83 ec 08             	sub    $0x8,%esp
f01008ed:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008f0:	ff 34 85 40 3b 10 f0 	pushl  -0xfefc4c0(,%eax,4)
f01008f7:	ff 75 a8             	pushl  -0x58(%ebp)
f01008fa:	e8 ef 27 00 00       	call   f01030ee <strcmp>
f01008ff:	83 c4 10             	add    $0x10,%esp
f0100902:	85 c0                	test   %eax,%eax
f0100904:	75 21                	jne    f0100927 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f0100906:	83 ec 04             	sub    $0x4,%esp
f0100909:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010090c:	ff 75 08             	pushl  0x8(%ebp)
f010090f:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100912:	52                   	push   %edx
f0100913:	56                   	push   %esi
f0100914:	ff 14 85 48 3b 10 f0 	call   *-0xfefc4b8(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010091b:	83 c4 10             	add    $0x10,%esp
f010091e:	85 c0                	test   %eax,%eax
f0100920:	78 25                	js     f0100947 <monitor+0x12c>
f0100922:	e9 16 ff ff ff       	jmp    f010083d <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100927:	83 c3 01             	add    $0x1,%ebx
f010092a:	83 fb 03             	cmp    $0x3,%ebx
f010092d:	75 bb                	jne    f01008ea <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010092f:	83 ec 08             	sub    $0x8,%esp
f0100932:	ff 75 a8             	pushl  -0x58(%ebp)
f0100935:	68 7f 39 10 f0       	push   $0xf010397f
f010093a:	e8 91 1d 00 00       	call   f01026d0 <cprintf>
f010093f:	83 c4 10             	add    $0x10,%esp
f0100942:	e9 f6 fe ff ff       	jmp    f010083d <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100947:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010094a:	5b                   	pop    %ebx
f010094b:	5e                   	pop    %esi
f010094c:	5f                   	pop    %edi
f010094d:	5d                   	pop    %ebp
f010094e:	c3                   	ret    

f010094f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010094f:	55                   	push   %ebp
f0100950:	89 e5                	mov    %esp,%ebp
f0100952:	56                   	push   %esi
f0100953:	53                   	push   %ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100954:	83 3d 38 65 11 f0 00 	cmpl   $0x0,0xf0116538
f010095b:	75 11                	jne    f010096e <boot_alloc+0x1f>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010095d:	ba 6f 79 11 f0       	mov    $0xf011796f,%edx
f0100962:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100968:	89 15 38 65 11 f0    	mov    %edx,0xf0116538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f010096e:	8b 1d 38 65 11 f0    	mov    0xf0116538,%ebx
	nextfree = ROUNDUP(result+n, PGSIZE);
f0100974:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f010097b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100981:	89 15 38 65 11 f0    	mov    %edx,0xf0116538
	
	if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE) {
f0100987:	8d b2 00 00 00 10    	lea    0x10000000(%edx),%esi
f010098d:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0100993:	c1 e1 0c             	shl    $0xc,%ecx
f0100996:	39 ce                	cmp    %ecx,%esi
f0100998:	76 17                	jbe    f01009b1 <boot_alloc+0x62>
		panic("file: pmap.c\nfunction: boot_alloc\nMore memory allocated than possible\nresult -> %p\nn -> %d\nnextfree -> %p", result, n, nextfree);
f010099a:	83 ec 08             	sub    $0x8,%esp
f010099d:	52                   	push   %edx
f010099e:	50                   	push   %eax
f010099f:	53                   	push   %ebx
f01009a0:	68 64 3b 10 f0       	push   $0xf0103b64
f01009a5:	6a 69                	push   $0x69
f01009a7:	68 ec 42 10 f0       	push   $0xf01042ec
f01009ac:	e8 0b f7 ff ff       	call   f01000bc <_panic>
	}
	return result;
}
f01009b1:	89 d8                	mov    %ebx,%eax
f01009b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009b6:	5b                   	pop    %ebx
f01009b7:	5e                   	pop    %esi
f01009b8:	5d                   	pop    %ebp
f01009b9:	c3                   	ret    

f01009ba <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009ba:	89 d1                	mov    %edx,%ecx
f01009bc:	c1 e9 16             	shr    $0x16,%ecx
f01009bf:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009c2:	a8 01                	test   $0x1,%al
f01009c4:	74 52                	je     f0100a18 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009cb:	89 c1                	mov    %eax,%ecx
f01009cd:	c1 e9 0c             	shr    $0xc,%ecx
f01009d0:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f01009d6:	72 1b                	jb     f01009f3 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009d8:	55                   	push   %ebp
f01009d9:	89 e5                	mov    %esp,%ebp
f01009db:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009de:	50                   	push   %eax
f01009df:	68 d0 3b 10 f0       	push   $0xf0103bd0
f01009e4:	68 d3 02 00 00       	push   $0x2d3
f01009e9:	68 ec 42 10 f0       	push   $0xf01042ec
f01009ee:	e8 c9 f6 ff ff       	call   f01000bc <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009f3:	c1 ea 0c             	shr    $0xc,%edx
f01009f6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009fc:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a03:	89 c2                	mov    %eax,%edx
f0100a05:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a0d:	85 d2                	test   %edx,%edx
f0100a0f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a14:	0f 44 c2             	cmove  %edx,%eax
f0100a17:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a1d:	c3                   	ret    

f0100a1e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a1e:	55                   	push   %ebp
f0100a1f:	89 e5                	mov    %esp,%ebp
f0100a21:	57                   	push   %edi
f0100a22:	56                   	push   %esi
f0100a23:	53                   	push   %ebx
f0100a24:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a27:	84 c0                	test   %al,%al
f0100a29:	0f 85 72 02 00 00    	jne    f0100ca1 <check_page_free_list+0x283>
f0100a2f:	e9 7f 02 00 00       	jmp    f0100cb3 <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a34:	83 ec 04             	sub    $0x4,%esp
f0100a37:	68 f4 3b 10 f0       	push   $0xf0103bf4
f0100a3c:	68 18 02 00 00       	push   $0x218
f0100a41:	68 ec 42 10 f0       	push   $0xf01042ec
f0100a46:	e8 71 f6 ff ff       	call   f01000bc <_panic>
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a4b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a4e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a51:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a54:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a57:	89 c2                	mov    %eax,%edx
f0100a59:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0100a5f:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a65:	0f 95 c2             	setne  %dl
f0100a68:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a6b:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a6f:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a71:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a75:	8b 00                	mov    (%eax),%eax
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	75 dc                	jne    f0100a57 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a7e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a87:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a8a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a8f:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a94:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a99:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100a9f:	eb 53                	jmp    f0100af4 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100aa1:	89 d8                	mov    %ebx,%eax
f0100aa3:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100aa9:	c1 f8 03             	sar    $0x3,%eax
f0100aac:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100aaf:	89 c2                	mov    %eax,%edx
f0100ab1:	c1 ea 16             	shr    $0x16,%edx
f0100ab4:	39 f2                	cmp    %esi,%edx
f0100ab6:	73 3a                	jae    f0100af2 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ab8:	89 c2                	mov    %eax,%edx
f0100aba:	c1 ea 0c             	shr    $0xc,%edx
f0100abd:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100ac3:	72 12                	jb     f0100ad7 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ac5:	50                   	push   %eax
f0100ac6:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0100acb:	6a 52                	push   $0x52
f0100acd:	68 f8 42 10 f0       	push   $0xf01042f8
f0100ad2:	e8 e5 f5 ff ff       	call   f01000bc <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ad7:	83 ec 04             	sub    $0x4,%esp
f0100ada:	68 80 00 00 00       	push   $0x80
f0100adf:	68 97 00 00 00       	push   $0x97
f0100ae4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ae9:	50                   	push   %eax
f0100aea:	e8 9a 26 00 00       	call   f0103189 <memset>
f0100aef:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100af2:	8b 1b                	mov    (%ebx),%ebx
f0100af4:	85 db                	test   %ebx,%ebx
f0100af6:	75 a9                	jne    f0100aa1 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100af8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100afd:	e8 4d fe ff ff       	call   f010094f <boot_alloc>
f0100b02:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b05:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b0b:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
		assert(pp < pages + npages);
f0100b11:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0100b16:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b19:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b1c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b1f:	be 00 00 00 00       	mov    $0x0,%esi
f0100b24:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b27:	e9 30 01 00 00       	jmp    f0100c5c <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b2c:	39 ca                	cmp    %ecx,%edx
f0100b2e:	73 19                	jae    f0100b49 <check_page_free_list+0x12b>
f0100b30:	68 06 43 10 f0       	push   $0xf0104306
f0100b35:	68 12 43 10 f0       	push   $0xf0104312
f0100b3a:	68 31 02 00 00       	push   $0x231
f0100b3f:	68 ec 42 10 f0       	push   $0xf01042ec
f0100b44:	e8 73 f5 ff ff       	call   f01000bc <_panic>
		assert(pp < pages + npages);
f0100b49:	39 fa                	cmp    %edi,%edx
f0100b4b:	72 19                	jb     f0100b66 <check_page_free_list+0x148>
f0100b4d:	68 27 43 10 f0       	push   $0xf0104327
f0100b52:	68 12 43 10 f0       	push   $0xf0104312
f0100b57:	68 32 02 00 00       	push   $0x232
f0100b5c:	68 ec 42 10 f0       	push   $0xf01042ec
f0100b61:	e8 56 f5 ff ff       	call   f01000bc <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b66:	89 d0                	mov    %edx,%eax
f0100b68:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b6b:	a8 07                	test   $0x7,%al
f0100b6d:	74 19                	je     f0100b88 <check_page_free_list+0x16a>
f0100b6f:	68 18 3c 10 f0       	push   $0xf0103c18
f0100b74:	68 12 43 10 f0       	push   $0xf0104312
f0100b79:	68 33 02 00 00       	push   $0x233
f0100b7e:	68 ec 42 10 f0       	push   $0xf01042ec
f0100b83:	e8 34 f5 ff ff       	call   f01000bc <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b88:	c1 f8 03             	sar    $0x3,%eax
f0100b8b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b8e:	85 c0                	test   %eax,%eax
f0100b90:	75 19                	jne    f0100bab <check_page_free_list+0x18d>
f0100b92:	68 3b 43 10 f0       	push   $0xf010433b
f0100b97:	68 12 43 10 f0       	push   $0xf0104312
f0100b9c:	68 36 02 00 00       	push   $0x236
f0100ba1:	68 ec 42 10 f0       	push   $0xf01042ec
f0100ba6:	e8 11 f5 ff ff       	call   f01000bc <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bab:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bb0:	75 19                	jne    f0100bcb <check_page_free_list+0x1ad>
f0100bb2:	68 4c 43 10 f0       	push   $0xf010434c
f0100bb7:	68 12 43 10 f0       	push   $0xf0104312
f0100bbc:	68 37 02 00 00       	push   $0x237
f0100bc1:	68 ec 42 10 f0       	push   $0xf01042ec
f0100bc6:	e8 f1 f4 ff ff       	call   f01000bc <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bcb:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bd0:	75 19                	jne    f0100beb <check_page_free_list+0x1cd>
f0100bd2:	68 4c 3c 10 f0       	push   $0xf0103c4c
f0100bd7:	68 12 43 10 f0       	push   $0xf0104312
f0100bdc:	68 38 02 00 00       	push   $0x238
f0100be1:	68 ec 42 10 f0       	push   $0xf01042ec
f0100be6:	e8 d1 f4 ff ff       	call   f01000bc <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100beb:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bf0:	75 19                	jne    f0100c0b <check_page_free_list+0x1ed>
f0100bf2:	68 65 43 10 f0       	push   $0xf0104365
f0100bf7:	68 12 43 10 f0       	push   $0xf0104312
f0100bfc:	68 39 02 00 00       	push   $0x239
f0100c01:	68 ec 42 10 f0       	push   $0xf01042ec
f0100c06:	e8 b1 f4 ff ff       	call   f01000bc <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c0b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c10:	76 3f                	jbe    f0100c51 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c12:	89 c3                	mov    %eax,%ebx
f0100c14:	c1 eb 0c             	shr    $0xc,%ebx
f0100c17:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c1a:	77 12                	ja     f0100c2e <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c1c:	50                   	push   %eax
f0100c1d:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0100c22:	6a 52                	push   $0x52
f0100c24:	68 f8 42 10 f0       	push   $0xf01042f8
f0100c29:	e8 8e f4 ff ff       	call   f01000bc <_panic>
f0100c2e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c33:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c36:	76 1e                	jbe    f0100c56 <check_page_free_list+0x238>
f0100c38:	68 70 3c 10 f0       	push   $0xf0103c70
f0100c3d:	68 12 43 10 f0       	push   $0xf0104312
f0100c42:	68 3a 02 00 00       	push   $0x23a
f0100c47:	68 ec 42 10 f0       	push   $0xf01042ec
f0100c4c:	e8 6b f4 ff ff       	call   f01000bc <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c51:	83 c6 01             	add    $0x1,%esi
f0100c54:	eb 04                	jmp    f0100c5a <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c56:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c5a:	8b 12                	mov    (%edx),%edx
f0100c5c:	85 d2                	test   %edx,%edx
f0100c5e:	0f 85 c8 fe ff ff    	jne    f0100b2c <check_page_free_list+0x10e>
f0100c64:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
		else
			++nfree_extmem;
	}
	assert(nfree_basemem > 0);
f0100c67:	85 f6                	test   %esi,%esi
f0100c69:	7f 19                	jg     f0100c84 <check_page_free_list+0x266>
f0100c6b:	68 7f 43 10 f0       	push   $0xf010437f
f0100c70:	68 12 43 10 f0       	push   $0xf0104312
f0100c75:	68 41 02 00 00       	push   $0x241
f0100c7a:	68 ec 42 10 f0       	push   $0xf01042ec
f0100c7f:	e8 38 f4 ff ff       	call   f01000bc <_panic>
	assert(nfree_extmem > 0);
f0100c84:	85 db                	test   %ebx,%ebx
f0100c86:	7f 42                	jg     f0100cca <check_page_free_list+0x2ac>
f0100c88:	68 91 43 10 f0       	push   $0xf0104391
f0100c8d:	68 12 43 10 f0       	push   $0xf0104312
f0100c92:	68 42 02 00 00       	push   $0x242
f0100c97:	68 ec 42 10 f0       	push   $0xf01042ec
f0100c9c:	e8 1b f4 ff ff       	call   f01000bc <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ca1:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0100ca6:	85 c0                	test   %eax,%eax
f0100ca8:	0f 85 9d fd ff ff    	jne    f0100a4b <check_page_free_list+0x2d>
f0100cae:	e9 81 fd ff ff       	jmp    f0100a34 <check_page_free_list+0x16>
f0100cb3:	83 3d 3c 65 11 f0 00 	cmpl   $0x0,0xf011653c
f0100cba:	0f 84 74 fd ff ff    	je     f0100a34 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cc0:	be 00 04 00 00       	mov    $0x400,%esi
f0100cc5:	e9 cf fd ff ff       	jmp    f0100a99 <check_page_free_list+0x7b>
		else
			++nfree_extmem;
	}
	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ccd:	5b                   	pop    %ebx
f0100cce:	5e                   	pop    %esi
f0100ccf:	5f                   	pop    %edi
f0100cd0:	5d                   	pop    %ebp
f0100cd1:	c3                   	ret    

f0100cd2 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cd2:	55                   	push   %ebp
f0100cd3:	89 e5                	mov    %esp,%ebp
f0100cd5:	57                   	push   %edi
f0100cd6:	56                   	push   %esi
f0100cd7:	53                   	push   %ebx
f0100cd8:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
f0100cdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ce0:	e8 6a fc ff ff       	call   f010094f <boot_alloc>
f0100ce5:	05 00 00 00 10       	add    $0x10000000,%eax
f0100cea:	c1 e8 0c             	shr    $0xc,%eax
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
		if (0 == i || ((i >= npages_basemem) && (i < (npages_basemem + num_of_io_pages))) \
f0100ced:	8b 0d 40 65 11 f0    	mov    0xf0116540,%ecx
f0100cf3:	8d 59 60             	lea    0x60(%ecx),%ebx
f0100cf6:	8b 35 3c 65 11 f0    	mov    0xf011653c,%esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
f0100cfc:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d01:	ba 00 00 00 00       	mov    $0x0,%edx
		if (0 == i || ((i >= npages_basemem) && (i < (npages_basemem + num_of_io_pages))) \
            || ((i >= npages_basemem + num_of_io_pages) && \
f0100d06:	01 d8                	add    %ebx,%eax
f0100d08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
f0100d0b:	eb 4c                	jmp    f0100d59 <page_init+0x87>
		if (0 == i || ((i >= npages_basemem) && (i < (npages_basemem + num_of_io_pages))) \
f0100d0d:	85 d2                	test   %edx,%edx
f0100d0f:	74 13                	je     f0100d24 <page_init+0x52>
f0100d11:	39 ca                	cmp    %ecx,%edx
f0100d13:	72 06                	jb     f0100d1b <page_init+0x49>
f0100d15:	39 da                	cmp    %ebx,%edx
f0100d17:	72 0b                	jb     f0100d24 <page_init+0x52>
f0100d19:	eb 04                	jmp    f0100d1f <page_init+0x4d>
            || ((i >= npages_basemem + num_of_io_pages) && \
f0100d1b:	39 da                	cmp    %ebx,%edx
f0100d1d:	72 13                	jb     f0100d32 <page_init+0x60>
f0100d1f:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100d22:	73 0e                	jae    f0100d32 <page_init+0x60>
            ( i < (npages_basemem + num_of_io_pages+num_of_kern_pages_plus_pgdir)))) {
			pages[i].pp_ref = 1;
f0100d24:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
f0100d29:	66 c7 44 d0 04 01 00 	movw   $0x1,0x4(%eax,%edx,8)
			continue;
f0100d30:	eb 24                	jmp    f0100d56 <page_init+0x84>
f0100d32:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
		}
		pages[i].pp_ref = 0;
f0100d39:	89 c7                	mov    %eax,%edi
f0100d3b:	03 3d 6c 69 11 f0    	add    0xf011696c,%edi
f0100d41:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f0100d47:	89 37                	mov    %esi,(%edi)
		page_free_list = &pages[i];
f0100d49:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100d4f:	89 c6                	mov    %eax,%esi
f0100d51:	bf 01 00 00 00       	mov    $0x1,%edi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
f0100d56:	83 c2 01             	add    $0x1,%edx
f0100d59:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100d5f:	72 ac                	jb     f0100d0d <page_init+0x3b>
f0100d61:	89 f8                	mov    %edi,%eax
f0100d63:	84 c0                	test   %al,%al
f0100d65:	74 06                	je     f0100d6d <page_init+0x9b>
f0100d67:	89 35 3c 65 11 f0    	mov    %esi,0xf011653c
		}
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100d6d:	83 c4 1c             	add    $0x1c,%esp
f0100d70:	5b                   	pop    %ebx
f0100d71:	5e                   	pop    %esi
f0100d72:	5f                   	pop    %edi
f0100d73:	5d                   	pop    %ebp
f0100d74:	c3                   	ret    

f0100d75 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d75:	55                   	push   %ebp
f0100d76:	89 e5                	mov    %esp,%ebp
f0100d78:	53                   	push   %ebx
f0100d79:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if (page_free_list == NULL){
f0100d7c:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100d82:	85 db                	test   %ebx,%ebx
f0100d84:	74 58                	je     f0100dde <page_alloc+0x69>
		return NULL;
	}
	struct PageInfo * temp;
	temp = page_free_list;
	//assert(temp->pp_ref == 0);
	page_free_list = page_free_list->pp_link;
f0100d86:	8b 03                	mov    (%ebx),%eax
f0100d88:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
	temp->pp_link = NULL;
f0100d8d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO){
f0100d93:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d97:	74 45                	je     f0100dde <page_alloc+0x69>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d99:	89 d8                	mov    %ebx,%eax
f0100d9b:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100da1:	c1 f8 03             	sar    $0x3,%eax
f0100da4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100da7:	89 c2                	mov    %eax,%edx
f0100da9:	c1 ea 0c             	shr    $0xc,%edx
f0100dac:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100db2:	72 12                	jb     f0100dc6 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100db4:	50                   	push   %eax
f0100db5:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0100dba:	6a 52                	push   $0x52
f0100dbc:	68 f8 42 10 f0       	push   $0xf01042f8
f0100dc1:	e8 f6 f2 ff ff       	call   f01000bc <_panic>
		memset(page2kva(temp), 0, PGSIZE);
f0100dc6:	83 ec 04             	sub    $0x4,%esp
f0100dc9:	68 00 10 00 00       	push   $0x1000
f0100dce:	6a 00                	push   $0x0
f0100dd0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dd5:	50                   	push   %eax
f0100dd6:	e8 ae 23 00 00       	call   f0103189 <memset>
f0100ddb:	83 c4 10             	add    $0x10,%esp
	}
	return temp;

}
f0100dde:	89 d8                	mov    %ebx,%eax
f0100de0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100de3:	c9                   	leave  
f0100de4:	c3                   	ret    

f0100de5 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100de5:	55                   	push   %ebp
f0100de6:	89 e5                	mov    %esp,%ebp
f0100de8:	83 ec 08             	sub    $0x8,%esp
f0100deb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	assert(pp->pp_ref == 0);
f0100dee:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100df3:	74 19                	je     f0100e0e <page_free+0x29>
f0100df5:	68 a2 43 10 f0       	push   $0xf01043a2
f0100dfa:	68 12 43 10 f0       	push   $0xf0104312
f0100dff:	68 37 01 00 00       	push   $0x137
f0100e04:	68 ec 42 10 f0       	push   $0xf01042ec
f0100e09:	e8 ae f2 ff ff       	call   f01000bc <_panic>
	pp->pp_link = page_free_list;
f0100e0e:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
f0100e14:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e16:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
	return;
}
f0100e1b:	c9                   	leave  
f0100e1c:	c3                   	ret    

f0100e1d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e1d:	55                   	push   %ebp
f0100e1e:	89 e5                	mov    %esp,%ebp
f0100e20:	83 ec 08             	sub    $0x8,%esp
f0100e23:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e26:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e2a:	83 e8 01             	sub    $0x1,%eax
f0100e2d:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e31:	66 85 c0             	test   %ax,%ax
f0100e34:	75 0c                	jne    f0100e42 <page_decref+0x25>
		page_free(pp);
f0100e36:	83 ec 0c             	sub    $0xc,%esp
f0100e39:	52                   	push   %edx
f0100e3a:	e8 a6 ff ff ff       	call   f0100de5 <page_free>
f0100e3f:	83 c4 10             	add    $0x10,%esp
}
f0100e42:	c9                   	leave  
f0100e43:	c3                   	ret    

f0100e44 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e44:	55                   	push   %ebp
f0100e45:	89 e5                	mov    %esp,%ebp
f0100e47:	56                   	push   %esi
f0100e48:	53                   	push   %ebx
f0100e49:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e4c:	8b 55 10             	mov    0x10(%ebp),%edx
	// Fill this function in
	pde_t * pde;
	struct PageInfo * newPage;
	pde = &pgdir[PDX(va)];
f0100e4f:	89 f3                	mov    %esi,%ebx
f0100e51:	c1 eb 16             	shr    $0x16,%ebx
f0100e54:	c1 e3 02             	shl    $0x2,%ebx
f0100e57:	03 5d 08             	add    0x8(%ebp),%ebx

	if (!(*pde & PTE_P) && !create){
f0100e5a:	8b 03                	mov    (%ebx),%eax
f0100e5c:	83 f0 01             	xor    $0x1,%eax
f0100e5f:	83 e0 01             	and    $0x1,%eax
f0100e62:	85 d2                	test   %edx,%edx
f0100e64:	75 04                	jne    f0100e6a <pgdir_walk+0x26>
f0100e66:	84 c0                	test   %al,%al
f0100e68:	75 6a                	jne    f0100ed4 <pgdir_walk+0x90>
		return NULL;
	}
	if ( !(*pde & PTE_P) && create){
f0100e6a:	85 d2                	test   %edx,%edx
f0100e6c:	74 2b                	je     f0100e99 <pgdir_walk+0x55>
f0100e6e:	84 c0                	test   %al,%al
f0100e70:	74 27                	je     f0100e99 <pgdir_walk+0x55>
		newPage = (struct PageInfo *) page_alloc(1);
f0100e72:	83 ec 0c             	sub    $0xc,%esp
f0100e75:	6a 01                	push   $0x1
f0100e77:	e8 f9 fe ff ff       	call   f0100d75 <page_alloc>
		if (newPage == NULL){	
f0100e7c:	83 c4 10             	add    $0x10,%esp
f0100e7f:	85 c0                	test   %eax,%eax
f0100e81:	74 58                	je     f0100edb <pgdir_walk+0x97>
			return NULL;
		}
		newPage->pp_ref += 1;
f0100e83:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		*pde = (page2pa(newPage) | PTE_P | PTE_W | PTE_U );
f0100e88:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100e8e:	c1 f8 03             	sar    $0x3,%eax
f0100e91:	c1 e0 0c             	shl    $0xc,%eax
f0100e94:	83 c8 07             	or     $0x7,%eax
f0100e97:	89 03                	mov    %eax,(%ebx)
		
	}
	pte_t * temp = KADDR(PTE_ADDR(*pde));
f0100e99:	8b 03                	mov    (%ebx),%eax
f0100e9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ea0:	89 c2                	mov    %eax,%edx
f0100ea2:	c1 ea 0c             	shr    $0xc,%edx
f0100ea5:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100eab:	72 15                	jb     f0100ec2 <pgdir_walk+0x7e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ead:	50                   	push   %eax
f0100eae:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0100eb3:	68 72 01 00 00       	push   $0x172
f0100eb8:	68 ec 42 10 f0       	push   $0xf01042ec
f0100ebd:	e8 fa f1 ff ff       	call   f01000bc <_panic>
	return &temp[PTX(va)];
f0100ec2:	c1 ee 0a             	shr    $0xa,%esi
f0100ec5:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100ecb:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100ed2:	eb 0c                	jmp    f0100ee0 <pgdir_walk+0x9c>
	pde_t * pde;
	struct PageInfo * newPage;
	pde = &pgdir[PDX(va)];

	if (!(*pde & PTE_P) && !create){
		return NULL;
f0100ed4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed9:	eb 05                	jmp    f0100ee0 <pgdir_walk+0x9c>
	}
	if ( !(*pde & PTE_P) && create){
		newPage = (struct PageInfo *) page_alloc(1);
		if (newPage == NULL){	
			return NULL;
f0100edb:	b8 00 00 00 00       	mov    $0x0,%eax
		*pde = (page2pa(newPage) | PTE_P | PTE_W | PTE_U );
		
	}
	pte_t * temp = KADDR(PTE_ADDR(*pde));
	return &temp[PTX(va)];
}
f0100ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ee3:	5b                   	pop    %ebx
f0100ee4:	5e                   	pop    %esi
f0100ee5:	5d                   	pop    %ebp
f0100ee6:	c3                   	ret    

f0100ee7 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100ee7:	55                   	push   %ebp
f0100ee8:	89 e5                	mov    %esp,%ebp
f0100eea:	57                   	push   %edi
f0100eeb:	56                   	push   %esi
f0100eec:	53                   	push   %ebx
f0100eed:	83 ec 1c             	sub    $0x1c,%esp
f0100ef0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Fill this function in
	uint32_t final_va = va + size;
f0100ef3:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f0100ef6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t current_va = va;
f0100ef9:	89 d3                	mov    %edx,%ebx
f0100efb:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100efe:	29 d7                	sub    %edx,%edi
	physaddr_t current_pa = pa;
	uint32_t last_page_addr = 4294963200LL;
	pte_t * temp;
	while(current_va < final_va){
		temp = pgdir_walk(pgdir, (void *)current_va, true);
		*temp = (current_pa | perm | PTE_P);
f0100f00:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f03:	83 c8 01             	or     $0x1,%eax
f0100f06:	89 45 dc             	mov    %eax,-0x24(%ebp)
	uint32_t final_va = va + size;
	uintptr_t current_va = va;
	physaddr_t current_pa = pa;
	uint32_t last_page_addr = 4294963200LL;
	pte_t * temp;
	while(current_va < final_va){
f0100f09:	eb 24                	jmp    f0100f2f <boot_map_region+0x48>
		temp = pgdir_walk(pgdir, (void *)current_va, true);
f0100f0b:	83 ec 04             	sub    $0x4,%esp
f0100f0e:	6a 01                	push   $0x1
f0100f10:	53                   	push   %ebx
f0100f11:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f14:	e8 2b ff ff ff       	call   f0100e44 <pgdir_walk>
		*temp = (current_pa | perm | PTE_P);
f0100f19:	0b 75 dc             	or     -0x24(%ebp),%esi
f0100f1c:	89 30                	mov    %esi,(%eax)
		if (current_va == last_page_addr){
f0100f1e:	83 c4 10             	add    $0x10,%esp
f0100f21:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0100f27:	74 0e                	je     f0100f37 <boot_map_region+0x50>
			break;
		}
		current_pa += PGSIZE;
		current_va += PGSIZE;
f0100f29:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f2f:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
	uint32_t final_va = va + size;
	uintptr_t current_va = va;
	physaddr_t current_pa = pa;
	uint32_t last_page_addr = 4294963200LL;
	pte_t * temp;
	while(current_va < final_va){
f0100f32:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100f35:	72 d4                	jb     f0100f0b <boot_map_region+0x24>
			break;
		}
		current_pa += PGSIZE;
		current_va += PGSIZE;
	}
}
f0100f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f3a:	5b                   	pop    %ebx
f0100f3b:	5e                   	pop    %esi
f0100f3c:	5f                   	pop    %edi
f0100f3d:	5d                   	pop    %ebp
f0100f3e:	c3                   	ret    

f0100f3f <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f3f:	55                   	push   %ebp
f0100f40:	89 e5                	mov    %esp,%ebp
f0100f42:	53                   	push   %ebx
f0100f43:	83 ec 08             	sub    $0x8,%esp
f0100f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t * temp = pgdir_walk(pgdir, va, false);
f0100f49:	6a 00                	push   $0x0
f0100f4b:	ff 75 0c             	pushl  0xc(%ebp)
f0100f4e:	ff 75 08             	pushl  0x8(%ebp)
f0100f51:	e8 ee fe ff ff       	call   f0100e44 <pgdir_walk>
	if (temp == NULL){
		return NULL;
	}
	if (pte_store == NULL) {
f0100f56:	83 c4 10             	add    $0x10,%esp
f0100f59:	85 c0                	test   %eax,%eax
f0100f5b:	74 32                	je     f0100f8f <page_lookup+0x50>
f0100f5d:	85 db                	test   %ebx,%ebx
f0100f5f:	74 2e                	je     f0100f8f <page_lookup+0x50>
		return NULL;
	}
	*pte_store = temp;
f0100f61:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f63:	8b 00                	mov    (%eax),%eax
f0100f65:	c1 e8 0c             	shr    $0xc,%eax
f0100f68:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0100f6e:	72 14                	jb     f0100f84 <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0100f70:	83 ec 04             	sub    $0x4,%esp
f0100f73:	68 b8 3c 10 f0       	push   $0xf0103cb8
f0100f78:	6a 4b                	push   $0x4b
f0100f7a:	68 f8 42 10 f0       	push   $0xf01042f8
f0100f7f:	e8 38 f1 ff ff       	call   f01000bc <_panic>
	return &pages[PGNUM(pa)];
f0100f84:	8b 15 6c 69 11 f0    	mov    0xf011696c,%edx
f0100f8a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	physaddr_t pp = PTE_ADDR(*temp);
	return pa2page(pp);
f0100f8d:	eb 05                	jmp    f0100f94 <page_lookup+0x55>
	pte_t * temp = pgdir_walk(pgdir, va, false);
	if (temp == NULL){
		return NULL;
	}
	if (pte_store == NULL) {
		return NULL;
f0100f8f:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	*pte_store = temp;
	physaddr_t pp = PTE_ADDR(*temp);
	return pa2page(pp);
}
f0100f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f97:	c9                   	leave  
f0100f98:	c3                   	ret    

f0100f99 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f99:	55                   	push   %ebp
f0100f9a:	89 e5                	mov    %esp,%ebp
f0100f9c:	53                   	push   %ebx
f0100f9d:	83 ec 18             	sub    $0x18,%esp
f0100fa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * temp;
	struct PageInfo * pg_tmp = page_lookup(pgdir,va, &temp);
f0100fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fa6:	50                   	push   %eax
f0100fa7:	53                   	push   %ebx
f0100fa8:	ff 75 08             	pushl  0x8(%ebp)
f0100fab:	e8 8f ff ff ff       	call   f0100f3f <page_lookup>
	if (pg_tmp == NULL){
f0100fb0:	83 c4 10             	add    $0x10,%esp
f0100fb3:	85 c0                	test   %eax,%eax
f0100fb5:	74 18                	je     f0100fcf <page_remove+0x36>
		return;
	}
	page_decref(pg_tmp);
f0100fb7:	83 ec 0c             	sub    $0xc,%esp
f0100fba:	50                   	push   %eax
f0100fbb:	e8 5d fe ff ff       	call   f0100e1d <page_decref>
	//pte_t * temp2 = &pgdir[PDX[va]];
	//pte_t * temp3 = KADDR(PTE_ADDR(*temp2));
	//temp3[PTX[va]] = NULL;
	*temp = (*temp & 0);
f0100fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fc3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100fc9:	0f 01 3b             	invlpg (%ebx)
f0100fcc:	83 c4 10             	add    $0x10,%esp
	tlb_invalidate(pgdir,va);
	return;
}
f0100fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fd2:	c9                   	leave  
f0100fd3:	c3                   	ret    

f0100fd4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fd4:	55                   	push   %ebp
f0100fd5:	89 e5                	mov    %esp,%ebp
f0100fd7:	57                   	push   %edi
f0100fd8:	56                   	push   %esi
f0100fd9:	53                   	push   %ebx
f0100fda:	83 ec 10             	sub    $0x10,%esp
f0100fdd:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fe0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * temp;
	if ((temp = (pte_t *)pgdir_walk(pgdir,va, true)) == NULL){
f0100fe3:	6a 01                	push   $0x1
f0100fe5:	ff 75 10             	pushl  0x10(%ebp)
f0100fe8:	56                   	push   %esi
f0100fe9:	e8 56 fe ff ff       	call   f0100e44 <pgdir_walk>
f0100fee:	83 c4 10             	add    $0x10,%esp
f0100ff1:	85 c0                	test   %eax,%eax
f0100ff3:	74 44                	je     f0101039 <page_insert+0x65>
f0100ff5:	89 c7                	mov    %eax,%edi
		return -E_NO_MEM;
	}
	pp->pp_ref += 1;
f0100ff7:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*temp & PTE_P){
f0100ffc:	f6 00 01             	testb  $0x1,(%eax)
f0100fff:	74 0f                	je     f0101010 <page_insert+0x3c>
		page_remove(pgdir,va);
f0101001:	83 ec 08             	sub    $0x8,%esp
f0101004:	ff 75 10             	pushl  0x10(%ebp)
f0101007:	56                   	push   %esi
f0101008:	e8 8c ff ff ff       	call   f0100f99 <page_remove>
f010100d:	83 c4 10             	add    $0x10,%esp
	}
	*temp = (page2pa(pp) | perm | PTE_P);
f0101010:	2b 1d 6c 69 11 f0    	sub    0xf011696c,%ebx
f0101016:	c1 fb 03             	sar    $0x3,%ebx
f0101019:	c1 e3 0c             	shl    $0xc,%ebx
f010101c:	8b 45 14             	mov    0x14(%ebp),%eax
f010101f:	83 c8 01             	or     $0x1,%eax
f0101022:	09 c3                	or     %eax,%ebx
f0101024:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f0101026:	8b 45 10             	mov    0x10(%ebp),%eax
f0101029:	c1 e8 16             	shr    $0x16,%eax
f010102c:	8b 55 14             	mov    0x14(%ebp),%edx
f010102f:	09 14 86             	or     %edx,(%esi,%eax,4)
//	pgdir[PDX(va)] |= PTE_P;
	return 0;
f0101032:	b8 00 00 00 00       	mov    $0x0,%eax
f0101037:	eb 05                	jmp    f010103e <page_insert+0x6a>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t * temp;
	if ((temp = (pte_t *)pgdir_walk(pgdir,va, true)) == NULL){
		return -E_NO_MEM;
f0101039:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
	*temp = (page2pa(pp) | perm | PTE_P);
	pgdir[PDX(va)] |= perm;
//	pgdir[PDX(va)] |= PTE_P;
	return 0;
}
f010103e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101041:	5b                   	pop    %ebx
f0101042:	5e                   	pop    %esi
f0101043:	5f                   	pop    %edi
f0101044:	5d                   	pop    %ebp
f0101045:	c3                   	ret    

f0101046 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101046:	55                   	push   %ebp
f0101047:	89 e5                	mov    %esp,%ebp
f0101049:	57                   	push   %edi
f010104a:	56                   	push   %esi
f010104b:	53                   	push   %ebx
f010104c:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010104f:	6a 15                	push   $0x15
f0101051:	e8 13 16 00 00       	call   f0102669 <mc146818_read>
f0101056:	89 c3                	mov    %eax,%ebx
f0101058:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010105f:	e8 05 16 00 00       	call   f0102669 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101064:	c1 e0 08             	shl    $0x8,%eax
f0101067:	09 d8                	or     %ebx,%eax
f0101069:	c1 e0 0a             	shl    $0xa,%eax
f010106c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101072:	85 c0                	test   %eax,%eax
f0101074:	0f 48 c2             	cmovs  %edx,%eax
f0101077:	c1 f8 0c             	sar    $0xc,%eax
f010107a:	a3 40 65 11 f0       	mov    %eax,0xf0116540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010107f:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101086:	e8 de 15 00 00       	call   f0102669 <mc146818_read>
f010108b:	89 c3                	mov    %eax,%ebx
f010108d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101094:	e8 d0 15 00 00       	call   f0102669 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101099:	c1 e0 08             	shl    $0x8,%eax
f010109c:	09 d8                	or     %ebx,%eax
f010109e:	c1 e0 0a             	shl    $0xa,%eax
f01010a1:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010a7:	83 c4 10             	add    $0x10,%esp
f01010aa:	85 c0                	test   %eax,%eax
f01010ac:	0f 48 c2             	cmovs  %edx,%eax
f01010af:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01010b2:	85 c0                	test   %eax,%eax
f01010b4:	74 0e                	je     f01010c4 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01010b6:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01010bc:	89 15 64 69 11 f0    	mov    %edx,0xf0116964
f01010c2:	eb 0c                	jmp    f01010d0 <mem_init+0x8a>
	else
		npages = npages_basemem;
f01010c4:	8b 15 40 65 11 f0    	mov    0xf0116540,%edx
f01010ca:	89 15 64 69 11 f0    	mov    %edx,0xf0116964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01010d0:	c1 e0 0c             	shl    $0xc,%eax
f01010d3:	c1 e8 0a             	shr    $0xa,%eax
f01010d6:	50                   	push   %eax
f01010d7:	a1 40 65 11 f0       	mov    0xf0116540,%eax
f01010dc:	c1 e0 0c             	shl    $0xc,%eax
f01010df:	c1 e8 0a             	shr    $0xa,%eax
f01010e2:	50                   	push   %eax
f01010e3:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f01010e8:	c1 e0 0c             	shl    $0xc,%eax
f01010eb:	c1 e8 0a             	shr    $0xa,%eax
f01010ee:	50                   	push   %eax
f01010ef:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01010f4:	e8 d7 15 00 00       	call   f01026d0 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010f9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010fe:	e8 4c f8 ff ff       	call   f010094f <boot_alloc>
f0101103:	a3 68 69 11 f0       	mov    %eax,0xf0116968
	memset(kern_pgdir, 0, PGSIZE);
f0101108:	83 c4 0c             	add    $0xc,%esp
f010110b:	68 00 10 00 00       	push   $0x1000
f0101110:	6a 00                	push   $0x0
f0101112:	50                   	push   %eax
f0101113:	e8 71 20 00 00       	call   f0103189 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101118:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010111d:	83 c4 10             	add    $0x10,%esp
f0101120:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101125:	77 15                	ja     f010113c <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101127:	50                   	push   %eax
f0101128:	68 14 3d 10 f0       	push   $0xf0103d14
f010112d:	68 8f 00 00 00       	push   $0x8f
f0101132:	68 ec 42 10 f0       	push   $0xf01042ec
f0101137:	e8 80 ef ff ff       	call   f01000bc <_panic>
f010113c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101142:	83 ca 05             	or     $0x5,%edx
f0101145:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo)*npages);
f010114b:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0101150:	c1 e0 03             	shl    $0x3,%eax
f0101153:	e8 f7 f7 ff ff       	call   f010094f <boot_alloc>
f0101158:	a3 6c 69 11 f0       	mov    %eax,0xf011696c
	memset(pages,0, npages * sizeof(struct PageInfo));
f010115d:	83 ec 04             	sub    $0x4,%esp
f0101160:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0101166:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010116d:	52                   	push   %edx
f010116e:	6a 00                	push   $0x0
f0101170:	50                   	push   %eax
f0101171:	e8 13 20 00 00       	call   f0103189 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101176:	e8 57 fb ff ff       	call   f0100cd2 <page_init>

	check_page_free_list(1);
f010117b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101180:	e8 99 f8 ff ff       	call   f0100a1e <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101185:	83 c4 10             	add    $0x10,%esp
f0101188:	83 3d 6c 69 11 f0 00 	cmpl   $0x0,0xf011696c
f010118f:	75 17                	jne    f01011a8 <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0101191:	83 ec 04             	sub    $0x4,%esp
f0101194:	68 b2 43 10 f0       	push   $0xf01043b2
f0101199:	68 53 02 00 00       	push   $0x253
f010119e:	68 ec 42 10 f0       	push   $0xf01042ec
f01011a3:	e8 14 ef ff ff       	call   f01000bc <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011a8:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f01011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011b2:	eb 05                	jmp    f01011b9 <mem_init+0x173>
		++nfree;
f01011b4:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011b7:	8b 00                	mov    (%eax),%eax
f01011b9:	85 c0                	test   %eax,%eax
f01011bb:	75 f7                	jne    f01011b4 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01011bd:	83 ec 0c             	sub    $0xc,%esp
f01011c0:	6a 00                	push   $0x0
f01011c2:	e8 ae fb ff ff       	call   f0100d75 <page_alloc>
f01011c7:	89 c7                	mov    %eax,%edi
f01011c9:	83 c4 10             	add    $0x10,%esp
f01011cc:	85 c0                	test   %eax,%eax
f01011ce:	75 19                	jne    f01011e9 <mem_init+0x1a3>
f01011d0:	68 cd 43 10 f0       	push   $0xf01043cd
f01011d5:	68 12 43 10 f0       	push   $0xf0104312
f01011da:	68 5b 02 00 00       	push   $0x25b
f01011df:	68 ec 42 10 f0       	push   $0xf01042ec
f01011e4:	e8 d3 ee ff ff       	call   f01000bc <_panic>
	assert((pp1 = page_alloc(0)));
f01011e9:	83 ec 0c             	sub    $0xc,%esp
f01011ec:	6a 00                	push   $0x0
f01011ee:	e8 82 fb ff ff       	call   f0100d75 <page_alloc>
f01011f3:	89 c6                	mov    %eax,%esi
f01011f5:	83 c4 10             	add    $0x10,%esp
f01011f8:	85 c0                	test   %eax,%eax
f01011fa:	75 19                	jne    f0101215 <mem_init+0x1cf>
f01011fc:	68 e3 43 10 f0       	push   $0xf01043e3
f0101201:	68 12 43 10 f0       	push   $0xf0104312
f0101206:	68 5c 02 00 00       	push   $0x25c
f010120b:	68 ec 42 10 f0       	push   $0xf01042ec
f0101210:	e8 a7 ee ff ff       	call   f01000bc <_panic>
	assert((pp2 = page_alloc(0)));
f0101215:	83 ec 0c             	sub    $0xc,%esp
f0101218:	6a 00                	push   $0x0
f010121a:	e8 56 fb ff ff       	call   f0100d75 <page_alloc>
f010121f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101222:	83 c4 10             	add    $0x10,%esp
f0101225:	85 c0                	test   %eax,%eax
f0101227:	75 19                	jne    f0101242 <mem_init+0x1fc>
f0101229:	68 f9 43 10 f0       	push   $0xf01043f9
f010122e:	68 12 43 10 f0       	push   $0xf0104312
f0101233:	68 5d 02 00 00       	push   $0x25d
f0101238:	68 ec 42 10 f0       	push   $0xf01042ec
f010123d:	e8 7a ee ff ff       	call   f01000bc <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101242:	39 f7                	cmp    %esi,%edi
f0101244:	75 19                	jne    f010125f <mem_init+0x219>
f0101246:	68 0f 44 10 f0       	push   $0xf010440f
f010124b:	68 12 43 10 f0       	push   $0xf0104312
f0101250:	68 60 02 00 00       	push   $0x260
f0101255:	68 ec 42 10 f0       	push   $0xf01042ec
f010125a:	e8 5d ee ff ff       	call   f01000bc <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010125f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101262:	39 c6                	cmp    %eax,%esi
f0101264:	74 04                	je     f010126a <mem_init+0x224>
f0101266:	39 c7                	cmp    %eax,%edi
f0101268:	75 19                	jne    f0101283 <mem_init+0x23d>
f010126a:	68 38 3d 10 f0       	push   $0xf0103d38
f010126f:	68 12 43 10 f0       	push   $0xf0104312
f0101274:	68 61 02 00 00       	push   $0x261
f0101279:	68 ec 42 10 f0       	push   $0xf01042ec
f010127e:	e8 39 ee ff ff       	call   f01000bc <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101283:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101289:	8b 15 64 69 11 f0    	mov    0xf0116964,%edx
f010128f:	c1 e2 0c             	shl    $0xc,%edx
f0101292:	89 f8                	mov    %edi,%eax
f0101294:	29 c8                	sub    %ecx,%eax
f0101296:	c1 f8 03             	sar    $0x3,%eax
f0101299:	c1 e0 0c             	shl    $0xc,%eax
f010129c:	39 d0                	cmp    %edx,%eax
f010129e:	72 19                	jb     f01012b9 <mem_init+0x273>
f01012a0:	68 21 44 10 f0       	push   $0xf0104421
f01012a5:	68 12 43 10 f0       	push   $0xf0104312
f01012aa:	68 62 02 00 00       	push   $0x262
f01012af:	68 ec 42 10 f0       	push   $0xf01042ec
f01012b4:	e8 03 ee ff ff       	call   f01000bc <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01012b9:	89 f0                	mov    %esi,%eax
f01012bb:	29 c8                	sub    %ecx,%eax
f01012bd:	c1 f8 03             	sar    $0x3,%eax
f01012c0:	c1 e0 0c             	shl    $0xc,%eax
f01012c3:	39 c2                	cmp    %eax,%edx
f01012c5:	77 19                	ja     f01012e0 <mem_init+0x29a>
f01012c7:	68 3e 44 10 f0       	push   $0xf010443e
f01012cc:	68 12 43 10 f0       	push   $0xf0104312
f01012d1:	68 63 02 00 00       	push   $0x263
f01012d6:	68 ec 42 10 f0       	push   $0xf01042ec
f01012db:	e8 dc ed ff ff       	call   f01000bc <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01012e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012e3:	29 c8                	sub    %ecx,%eax
f01012e5:	c1 f8 03             	sar    $0x3,%eax
f01012e8:	c1 e0 0c             	shl    $0xc,%eax
f01012eb:	39 c2                	cmp    %eax,%edx
f01012ed:	77 19                	ja     f0101308 <mem_init+0x2c2>
f01012ef:	68 5b 44 10 f0       	push   $0xf010445b
f01012f4:	68 12 43 10 f0       	push   $0xf0104312
f01012f9:	68 64 02 00 00       	push   $0x264
f01012fe:	68 ec 42 10 f0       	push   $0xf01042ec
f0101303:	e8 b4 ed ff ff       	call   f01000bc <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101308:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f010130d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101310:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f0101317:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010131a:	83 ec 0c             	sub    $0xc,%esp
f010131d:	6a 00                	push   $0x0
f010131f:	e8 51 fa ff ff       	call   f0100d75 <page_alloc>
f0101324:	83 c4 10             	add    $0x10,%esp
f0101327:	85 c0                	test   %eax,%eax
f0101329:	74 19                	je     f0101344 <mem_init+0x2fe>
f010132b:	68 78 44 10 f0       	push   $0xf0104478
f0101330:	68 12 43 10 f0       	push   $0xf0104312
f0101335:	68 6b 02 00 00       	push   $0x26b
f010133a:	68 ec 42 10 f0       	push   $0xf01042ec
f010133f:	e8 78 ed ff ff       	call   f01000bc <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101344:	83 ec 0c             	sub    $0xc,%esp
f0101347:	57                   	push   %edi
f0101348:	e8 98 fa ff ff       	call   f0100de5 <page_free>
	page_free(pp1);
f010134d:	89 34 24             	mov    %esi,(%esp)
f0101350:	e8 90 fa ff ff       	call   f0100de5 <page_free>
	page_free(pp2);
f0101355:	83 c4 04             	add    $0x4,%esp
f0101358:	ff 75 d4             	pushl  -0x2c(%ebp)
f010135b:	e8 85 fa ff ff       	call   f0100de5 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101360:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101367:	e8 09 fa ff ff       	call   f0100d75 <page_alloc>
f010136c:	89 c6                	mov    %eax,%esi
f010136e:	83 c4 10             	add    $0x10,%esp
f0101371:	85 c0                	test   %eax,%eax
f0101373:	75 19                	jne    f010138e <mem_init+0x348>
f0101375:	68 cd 43 10 f0       	push   $0xf01043cd
f010137a:	68 12 43 10 f0       	push   $0xf0104312
f010137f:	68 72 02 00 00       	push   $0x272
f0101384:	68 ec 42 10 f0       	push   $0xf01042ec
f0101389:	e8 2e ed ff ff       	call   f01000bc <_panic>
	assert((pp1 = page_alloc(0)));
f010138e:	83 ec 0c             	sub    $0xc,%esp
f0101391:	6a 00                	push   $0x0
f0101393:	e8 dd f9 ff ff       	call   f0100d75 <page_alloc>
f0101398:	89 c7                	mov    %eax,%edi
f010139a:	83 c4 10             	add    $0x10,%esp
f010139d:	85 c0                	test   %eax,%eax
f010139f:	75 19                	jne    f01013ba <mem_init+0x374>
f01013a1:	68 e3 43 10 f0       	push   $0xf01043e3
f01013a6:	68 12 43 10 f0       	push   $0xf0104312
f01013ab:	68 73 02 00 00       	push   $0x273
f01013b0:	68 ec 42 10 f0       	push   $0xf01042ec
f01013b5:	e8 02 ed ff ff       	call   f01000bc <_panic>
	assert((pp2 = page_alloc(0)));
f01013ba:	83 ec 0c             	sub    $0xc,%esp
f01013bd:	6a 00                	push   $0x0
f01013bf:	e8 b1 f9 ff ff       	call   f0100d75 <page_alloc>
f01013c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013c7:	83 c4 10             	add    $0x10,%esp
f01013ca:	85 c0                	test   %eax,%eax
f01013cc:	75 19                	jne    f01013e7 <mem_init+0x3a1>
f01013ce:	68 f9 43 10 f0       	push   $0xf01043f9
f01013d3:	68 12 43 10 f0       	push   $0xf0104312
f01013d8:	68 74 02 00 00       	push   $0x274
f01013dd:	68 ec 42 10 f0       	push   $0xf01042ec
f01013e2:	e8 d5 ec ff ff       	call   f01000bc <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013e7:	39 fe                	cmp    %edi,%esi
f01013e9:	75 19                	jne    f0101404 <mem_init+0x3be>
f01013eb:	68 0f 44 10 f0       	push   $0xf010440f
f01013f0:	68 12 43 10 f0       	push   $0xf0104312
f01013f5:	68 76 02 00 00       	push   $0x276
f01013fa:	68 ec 42 10 f0       	push   $0xf01042ec
f01013ff:	e8 b8 ec ff ff       	call   f01000bc <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101404:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101407:	39 c7                	cmp    %eax,%edi
f0101409:	74 04                	je     f010140f <mem_init+0x3c9>
f010140b:	39 c6                	cmp    %eax,%esi
f010140d:	75 19                	jne    f0101428 <mem_init+0x3e2>
f010140f:	68 38 3d 10 f0       	push   $0xf0103d38
f0101414:	68 12 43 10 f0       	push   $0xf0104312
f0101419:	68 77 02 00 00       	push   $0x277
f010141e:	68 ec 42 10 f0       	push   $0xf01042ec
f0101423:	e8 94 ec ff ff       	call   f01000bc <_panic>
	assert(!page_alloc(0));
f0101428:	83 ec 0c             	sub    $0xc,%esp
f010142b:	6a 00                	push   $0x0
f010142d:	e8 43 f9 ff ff       	call   f0100d75 <page_alloc>
f0101432:	83 c4 10             	add    $0x10,%esp
f0101435:	85 c0                	test   %eax,%eax
f0101437:	74 19                	je     f0101452 <mem_init+0x40c>
f0101439:	68 78 44 10 f0       	push   $0xf0104478
f010143e:	68 12 43 10 f0       	push   $0xf0104312
f0101443:	68 78 02 00 00       	push   $0x278
f0101448:	68 ec 42 10 f0       	push   $0xf01042ec
f010144d:	e8 6a ec ff ff       	call   f01000bc <_panic>
f0101452:	89 f0                	mov    %esi,%eax
f0101454:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f010145a:	c1 f8 03             	sar    $0x3,%eax
f010145d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101460:	89 c2                	mov    %eax,%edx
f0101462:	c1 ea 0c             	shr    $0xc,%edx
f0101465:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f010146b:	72 12                	jb     f010147f <mem_init+0x439>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010146d:	50                   	push   %eax
f010146e:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0101473:	6a 52                	push   $0x52
f0101475:	68 f8 42 10 f0       	push   $0xf01042f8
f010147a:	e8 3d ec ff ff       	call   f01000bc <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010147f:	83 ec 04             	sub    $0x4,%esp
f0101482:	68 00 10 00 00       	push   $0x1000
f0101487:	6a 01                	push   $0x1
f0101489:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010148e:	50                   	push   %eax
f010148f:	e8 f5 1c 00 00       	call   f0103189 <memset>
	page_free(pp0);
f0101494:	89 34 24             	mov    %esi,(%esp)
f0101497:	e8 49 f9 ff ff       	call   f0100de5 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010149c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01014a3:	e8 cd f8 ff ff       	call   f0100d75 <page_alloc>
f01014a8:	83 c4 10             	add    $0x10,%esp
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	75 19                	jne    f01014c8 <mem_init+0x482>
f01014af:	68 87 44 10 f0       	push   $0xf0104487
f01014b4:	68 12 43 10 f0       	push   $0xf0104312
f01014b9:	68 7d 02 00 00       	push   $0x27d
f01014be:	68 ec 42 10 f0       	push   $0xf01042ec
f01014c3:	e8 f4 eb ff ff       	call   f01000bc <_panic>
	assert(pp && pp0 == pp);
f01014c8:	39 c6                	cmp    %eax,%esi
f01014ca:	74 19                	je     f01014e5 <mem_init+0x49f>
f01014cc:	68 a5 44 10 f0       	push   $0xf01044a5
f01014d1:	68 12 43 10 f0       	push   $0xf0104312
f01014d6:	68 7e 02 00 00       	push   $0x27e
f01014db:	68 ec 42 10 f0       	push   $0xf01042ec
f01014e0:	e8 d7 eb ff ff       	call   f01000bc <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014e5:	89 f0                	mov    %esi,%eax
f01014e7:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01014ed:	c1 f8 03             	sar    $0x3,%eax
f01014f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014f3:	89 c2                	mov    %eax,%edx
f01014f5:	c1 ea 0c             	shr    $0xc,%edx
f01014f8:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01014fe:	72 12                	jb     f0101512 <mem_init+0x4cc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101500:	50                   	push   %eax
f0101501:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0101506:	6a 52                	push   $0x52
f0101508:	68 f8 42 10 f0       	push   $0xf01042f8
f010150d:	e8 aa eb ff ff       	call   f01000bc <_panic>
f0101512:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101518:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010151e:	80 38 00             	cmpb   $0x0,(%eax)
f0101521:	74 19                	je     f010153c <mem_init+0x4f6>
f0101523:	68 b5 44 10 f0       	push   $0xf01044b5
f0101528:	68 12 43 10 f0       	push   $0xf0104312
f010152d:	68 81 02 00 00       	push   $0x281
f0101532:	68 ec 42 10 f0       	push   $0xf01042ec
f0101537:	e8 80 eb ff ff       	call   f01000bc <_panic>
f010153c:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010153f:	39 d0                	cmp    %edx,%eax
f0101541:	75 db                	jne    f010151e <mem_init+0x4d8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101543:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101546:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f010154b:	83 ec 0c             	sub    $0xc,%esp
f010154e:	56                   	push   %esi
f010154f:	e8 91 f8 ff ff       	call   f0100de5 <page_free>
	page_free(pp1);
f0101554:	89 3c 24             	mov    %edi,(%esp)
f0101557:	e8 89 f8 ff ff       	call   f0100de5 <page_free>
	page_free(pp2);
f010155c:	83 c4 04             	add    $0x4,%esp
f010155f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101562:	e8 7e f8 ff ff       	call   f0100de5 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101567:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f010156c:	83 c4 10             	add    $0x10,%esp
f010156f:	eb 05                	jmp    f0101576 <mem_init+0x530>
		--nfree;
f0101571:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101574:	8b 00                	mov    (%eax),%eax
f0101576:	85 c0                	test   %eax,%eax
f0101578:	75 f7                	jne    f0101571 <mem_init+0x52b>
		--nfree;
	assert(nfree == 0);
f010157a:	85 db                	test   %ebx,%ebx
f010157c:	74 19                	je     f0101597 <mem_init+0x551>
f010157e:	68 bf 44 10 f0       	push   $0xf01044bf
f0101583:	68 12 43 10 f0       	push   $0xf0104312
f0101588:	68 8e 02 00 00       	push   $0x28e
f010158d:	68 ec 42 10 f0       	push   $0xf01042ec
f0101592:	e8 25 eb ff ff       	call   f01000bc <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101597:	83 ec 0c             	sub    $0xc,%esp
f010159a:	68 58 3d 10 f0       	push   $0xf0103d58
f010159f:	e8 2c 11 00 00       	call   f01026d0 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ab:	e8 c5 f7 ff ff       	call   f0100d75 <page_alloc>
f01015b0:	89 c6                	mov    %eax,%esi
f01015b2:	83 c4 10             	add    $0x10,%esp
f01015b5:	85 c0                	test   %eax,%eax
f01015b7:	75 19                	jne    f01015d2 <mem_init+0x58c>
f01015b9:	68 cd 43 10 f0       	push   $0xf01043cd
f01015be:	68 12 43 10 f0       	push   $0xf0104312
f01015c3:	68 e7 02 00 00       	push   $0x2e7
f01015c8:	68 ec 42 10 f0       	push   $0xf01042ec
f01015cd:	e8 ea ea ff ff       	call   f01000bc <_panic>
	assert((pp1 = page_alloc(0)));
f01015d2:	83 ec 0c             	sub    $0xc,%esp
f01015d5:	6a 00                	push   $0x0
f01015d7:	e8 99 f7 ff ff       	call   f0100d75 <page_alloc>
f01015dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015df:	83 c4 10             	add    $0x10,%esp
f01015e2:	85 c0                	test   %eax,%eax
f01015e4:	75 19                	jne    f01015ff <mem_init+0x5b9>
f01015e6:	68 e3 43 10 f0       	push   $0xf01043e3
f01015eb:	68 12 43 10 f0       	push   $0xf0104312
f01015f0:	68 e8 02 00 00       	push   $0x2e8
f01015f5:	68 ec 42 10 f0       	push   $0xf01042ec
f01015fa:	e8 bd ea ff ff       	call   f01000bc <_panic>
	assert((pp2 = page_alloc(0)));
f01015ff:	83 ec 0c             	sub    $0xc,%esp
f0101602:	6a 00                	push   $0x0
f0101604:	e8 6c f7 ff ff       	call   f0100d75 <page_alloc>
f0101609:	89 c3                	mov    %eax,%ebx
f010160b:	83 c4 10             	add    $0x10,%esp
f010160e:	85 c0                	test   %eax,%eax
f0101610:	75 19                	jne    f010162b <mem_init+0x5e5>
f0101612:	68 f9 43 10 f0       	push   $0xf01043f9
f0101617:	68 12 43 10 f0       	push   $0xf0104312
f010161c:	68 e9 02 00 00       	push   $0x2e9
f0101621:	68 ec 42 10 f0       	push   $0xf01042ec
f0101626:	e8 91 ea ff ff       	call   f01000bc <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010162b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010162e:	75 19                	jne    f0101649 <mem_init+0x603>
f0101630:	68 0f 44 10 f0       	push   $0xf010440f
f0101635:	68 12 43 10 f0       	push   $0xf0104312
f010163a:	68 ec 02 00 00       	push   $0x2ec
f010163f:	68 ec 42 10 f0       	push   $0xf01042ec
f0101644:	e8 73 ea ff ff       	call   f01000bc <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101649:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010164c:	74 04                	je     f0101652 <mem_init+0x60c>
f010164e:	39 c6                	cmp    %eax,%esi
f0101650:	75 19                	jne    f010166b <mem_init+0x625>
f0101652:	68 38 3d 10 f0       	push   $0xf0103d38
f0101657:	68 12 43 10 f0       	push   $0xf0104312
f010165c:	68 ed 02 00 00       	push   $0x2ed
f0101661:	68 ec 42 10 f0       	push   $0xf01042ec
f0101666:	e8 51 ea ff ff       	call   f01000bc <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010166b:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101670:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101673:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f010167a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010167d:	83 ec 0c             	sub    $0xc,%esp
f0101680:	6a 00                	push   $0x0
f0101682:	e8 ee f6 ff ff       	call   f0100d75 <page_alloc>
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	85 c0                	test   %eax,%eax
f010168c:	74 19                	je     f01016a7 <mem_init+0x661>
f010168e:	68 78 44 10 f0       	push   $0xf0104478
f0101693:	68 12 43 10 f0       	push   $0xf0104312
f0101698:	68 f4 02 00 00       	push   $0x2f4
f010169d:	68 ec 42 10 f0       	push   $0xf01042ec
f01016a2:	e8 15 ea ff ff       	call   f01000bc <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01016a7:	83 ec 04             	sub    $0x4,%esp
f01016aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016ad:	50                   	push   %eax
f01016ae:	6a 00                	push   $0x0
f01016b0:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01016b6:	e8 84 f8 ff ff       	call   f0100f3f <page_lookup>
f01016bb:	83 c4 10             	add    $0x10,%esp
f01016be:	85 c0                	test   %eax,%eax
f01016c0:	74 19                	je     f01016db <mem_init+0x695>
f01016c2:	68 78 3d 10 f0       	push   $0xf0103d78
f01016c7:	68 12 43 10 f0       	push   $0xf0104312
f01016cc:	68 f7 02 00 00       	push   $0x2f7
f01016d1:	68 ec 42 10 f0       	push   $0xf01042ec
f01016d6:	e8 e1 e9 ff ff       	call   f01000bc <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016db:	6a 02                	push   $0x2
f01016dd:	6a 00                	push   $0x0
f01016df:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016e2:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01016e8:	e8 e7 f8 ff ff       	call   f0100fd4 <page_insert>
f01016ed:	83 c4 10             	add    $0x10,%esp
f01016f0:	85 c0                	test   %eax,%eax
f01016f2:	78 19                	js     f010170d <mem_init+0x6c7>
f01016f4:	68 b0 3d 10 f0       	push   $0xf0103db0
f01016f9:	68 12 43 10 f0       	push   $0xf0104312
f01016fe:	68 fa 02 00 00       	push   $0x2fa
f0101703:	68 ec 42 10 f0       	push   $0xf01042ec
f0101708:	e8 af e9 ff ff       	call   f01000bc <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010170d:	83 ec 0c             	sub    $0xc,%esp
f0101710:	56                   	push   %esi
f0101711:	e8 cf f6 ff ff       	call   f0100de5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101716:	6a 02                	push   $0x2
f0101718:	6a 00                	push   $0x0
f010171a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010171d:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101723:	e8 ac f8 ff ff       	call   f0100fd4 <page_insert>
f0101728:	83 c4 20             	add    $0x20,%esp
f010172b:	85 c0                	test   %eax,%eax
f010172d:	74 19                	je     f0101748 <mem_init+0x702>
f010172f:	68 e0 3d 10 f0       	push   $0xf0103de0
f0101734:	68 12 43 10 f0       	push   $0xf0104312
f0101739:	68 fe 02 00 00       	push   $0x2fe
f010173e:	68 ec 42 10 f0       	push   $0xf01042ec
f0101743:	e8 74 e9 ff ff       	call   f01000bc <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101748:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010174e:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
f0101753:	89 c1                	mov    %eax,%ecx
f0101755:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101758:	8b 17                	mov    (%edi),%edx
f010175a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101760:	89 f0                	mov    %esi,%eax
f0101762:	29 c8                	sub    %ecx,%eax
f0101764:	c1 f8 03             	sar    $0x3,%eax
f0101767:	c1 e0 0c             	shl    $0xc,%eax
f010176a:	39 c2                	cmp    %eax,%edx
f010176c:	74 19                	je     f0101787 <mem_init+0x741>
f010176e:	68 10 3e 10 f0       	push   $0xf0103e10
f0101773:	68 12 43 10 f0       	push   $0xf0104312
f0101778:	68 ff 02 00 00       	push   $0x2ff
f010177d:	68 ec 42 10 f0       	push   $0xf01042ec
f0101782:	e8 35 e9 ff ff       	call   f01000bc <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101787:	ba 00 00 00 00       	mov    $0x0,%edx
f010178c:	89 f8                	mov    %edi,%eax
f010178e:	e8 27 f2 ff ff       	call   f01009ba <check_va2pa>
f0101793:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101796:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101799:	c1 fa 03             	sar    $0x3,%edx
f010179c:	c1 e2 0c             	shl    $0xc,%edx
f010179f:	39 d0                	cmp    %edx,%eax
f01017a1:	74 19                	je     f01017bc <mem_init+0x776>
f01017a3:	68 38 3e 10 f0       	push   $0xf0103e38
f01017a8:	68 12 43 10 f0       	push   $0xf0104312
f01017ad:	68 00 03 00 00       	push   $0x300
f01017b2:	68 ec 42 10 f0       	push   $0xf01042ec
f01017b7:	e8 00 e9 ff ff       	call   f01000bc <_panic>
	assert(pp1->pp_ref == 1);
f01017bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017bf:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01017c4:	74 19                	je     f01017df <mem_init+0x799>
f01017c6:	68 ca 44 10 f0       	push   $0xf01044ca
f01017cb:	68 12 43 10 f0       	push   $0xf0104312
f01017d0:	68 01 03 00 00       	push   $0x301
f01017d5:	68 ec 42 10 f0       	push   $0xf01042ec
f01017da:	e8 dd e8 ff ff       	call   f01000bc <_panic>
	assert(pp0->pp_ref == 1);
f01017df:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01017e4:	74 19                	je     f01017ff <mem_init+0x7b9>
f01017e6:	68 db 44 10 f0       	push   $0xf01044db
f01017eb:	68 12 43 10 f0       	push   $0xf0104312
f01017f0:	68 02 03 00 00       	push   $0x302
f01017f5:	68 ec 42 10 f0       	push   $0xf01042ec
f01017fa:	e8 bd e8 ff ff       	call   f01000bc <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017ff:	6a 02                	push   $0x2
f0101801:	68 00 10 00 00       	push   $0x1000
f0101806:	53                   	push   %ebx
f0101807:	57                   	push   %edi
f0101808:	e8 c7 f7 ff ff       	call   f0100fd4 <page_insert>
f010180d:	83 c4 10             	add    $0x10,%esp
f0101810:	85 c0                	test   %eax,%eax
f0101812:	74 19                	je     f010182d <mem_init+0x7e7>
f0101814:	68 68 3e 10 f0       	push   $0xf0103e68
f0101819:	68 12 43 10 f0       	push   $0xf0104312
f010181e:	68 05 03 00 00       	push   $0x305
f0101823:	68 ec 42 10 f0       	push   $0xf01042ec
f0101828:	e8 8f e8 ff ff       	call   f01000bc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010182d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101832:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101837:	e8 7e f1 ff ff       	call   f01009ba <check_va2pa>
f010183c:	89 da                	mov    %ebx,%edx
f010183e:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101844:	c1 fa 03             	sar    $0x3,%edx
f0101847:	c1 e2 0c             	shl    $0xc,%edx
f010184a:	39 d0                	cmp    %edx,%eax
f010184c:	74 19                	je     f0101867 <mem_init+0x821>
f010184e:	68 a4 3e 10 f0       	push   $0xf0103ea4
f0101853:	68 12 43 10 f0       	push   $0xf0104312
f0101858:	68 06 03 00 00       	push   $0x306
f010185d:	68 ec 42 10 f0       	push   $0xf01042ec
f0101862:	e8 55 e8 ff ff       	call   f01000bc <_panic>
	assert(pp2->pp_ref == 1);
f0101867:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010186c:	74 19                	je     f0101887 <mem_init+0x841>
f010186e:	68 ec 44 10 f0       	push   $0xf01044ec
f0101873:	68 12 43 10 f0       	push   $0xf0104312
f0101878:	68 07 03 00 00       	push   $0x307
f010187d:	68 ec 42 10 f0       	push   $0xf01042ec
f0101882:	e8 35 e8 ff ff       	call   f01000bc <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101887:	83 ec 0c             	sub    $0xc,%esp
f010188a:	6a 00                	push   $0x0
f010188c:	e8 e4 f4 ff ff       	call   f0100d75 <page_alloc>
f0101891:	83 c4 10             	add    $0x10,%esp
f0101894:	85 c0                	test   %eax,%eax
f0101896:	74 19                	je     f01018b1 <mem_init+0x86b>
f0101898:	68 78 44 10 f0       	push   $0xf0104478
f010189d:	68 12 43 10 f0       	push   $0xf0104312
f01018a2:	68 0a 03 00 00       	push   $0x30a
f01018a7:	68 ec 42 10 f0       	push   $0xf01042ec
f01018ac:	e8 0b e8 ff ff       	call   f01000bc <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018b1:	6a 02                	push   $0x2
f01018b3:	68 00 10 00 00       	push   $0x1000
f01018b8:	53                   	push   %ebx
f01018b9:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01018bf:	e8 10 f7 ff ff       	call   f0100fd4 <page_insert>
f01018c4:	83 c4 10             	add    $0x10,%esp
f01018c7:	85 c0                	test   %eax,%eax
f01018c9:	74 19                	je     f01018e4 <mem_init+0x89e>
f01018cb:	68 68 3e 10 f0       	push   $0xf0103e68
f01018d0:	68 12 43 10 f0       	push   $0xf0104312
f01018d5:	68 0d 03 00 00       	push   $0x30d
f01018da:	68 ec 42 10 f0       	push   $0xf01042ec
f01018df:	e8 d8 e7 ff ff       	call   f01000bc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018e4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018e9:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01018ee:	e8 c7 f0 ff ff       	call   f01009ba <check_va2pa>
f01018f3:	89 da                	mov    %ebx,%edx
f01018f5:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01018fb:	c1 fa 03             	sar    $0x3,%edx
f01018fe:	c1 e2 0c             	shl    $0xc,%edx
f0101901:	39 d0                	cmp    %edx,%eax
f0101903:	74 19                	je     f010191e <mem_init+0x8d8>
f0101905:	68 a4 3e 10 f0       	push   $0xf0103ea4
f010190a:	68 12 43 10 f0       	push   $0xf0104312
f010190f:	68 0e 03 00 00       	push   $0x30e
f0101914:	68 ec 42 10 f0       	push   $0xf01042ec
f0101919:	e8 9e e7 ff ff       	call   f01000bc <_panic>
	assert(pp2->pp_ref == 1);
f010191e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101923:	74 19                	je     f010193e <mem_init+0x8f8>
f0101925:	68 ec 44 10 f0       	push   $0xf01044ec
f010192a:	68 12 43 10 f0       	push   $0xf0104312
f010192f:	68 0f 03 00 00       	push   $0x30f
f0101934:	68 ec 42 10 f0       	push   $0xf01042ec
f0101939:	e8 7e e7 ff ff       	call   f01000bc <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010193e:	83 ec 0c             	sub    $0xc,%esp
f0101941:	6a 00                	push   $0x0
f0101943:	e8 2d f4 ff ff       	call   f0100d75 <page_alloc>
f0101948:	83 c4 10             	add    $0x10,%esp
f010194b:	85 c0                	test   %eax,%eax
f010194d:	74 19                	je     f0101968 <mem_init+0x922>
f010194f:	68 78 44 10 f0       	push   $0xf0104478
f0101954:	68 12 43 10 f0       	push   $0xf0104312
f0101959:	68 13 03 00 00       	push   $0x313
f010195e:	68 ec 42 10 f0       	push   $0xf01042ec
f0101963:	e8 54 e7 ff ff       	call   f01000bc <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101968:	8b 15 68 69 11 f0    	mov    0xf0116968,%edx
f010196e:	8b 02                	mov    (%edx),%eax
f0101970:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101975:	89 c1                	mov    %eax,%ecx
f0101977:	c1 e9 0c             	shr    $0xc,%ecx
f010197a:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f0101980:	72 15                	jb     f0101997 <mem_init+0x951>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101982:	50                   	push   %eax
f0101983:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0101988:	68 16 03 00 00       	push   $0x316
f010198d:	68 ec 42 10 f0       	push   $0xf01042ec
f0101992:	e8 25 e7 ff ff       	call   f01000bc <_panic>
f0101997:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010199c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010199f:	83 ec 04             	sub    $0x4,%esp
f01019a2:	6a 00                	push   $0x0
f01019a4:	68 00 10 00 00       	push   $0x1000
f01019a9:	52                   	push   %edx
f01019aa:	e8 95 f4 ff ff       	call   f0100e44 <pgdir_walk>
f01019af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01019b2:	8d 51 04             	lea    0x4(%ecx),%edx
f01019b5:	83 c4 10             	add    $0x10,%esp
f01019b8:	39 d0                	cmp    %edx,%eax
f01019ba:	74 19                	je     f01019d5 <mem_init+0x98f>
f01019bc:	68 d4 3e 10 f0       	push   $0xf0103ed4
f01019c1:	68 12 43 10 f0       	push   $0xf0104312
f01019c6:	68 17 03 00 00       	push   $0x317
f01019cb:	68 ec 42 10 f0       	push   $0xf01042ec
f01019d0:	e8 e7 e6 ff ff       	call   f01000bc <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019d5:	6a 06                	push   $0x6
f01019d7:	68 00 10 00 00       	push   $0x1000
f01019dc:	53                   	push   %ebx
f01019dd:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01019e3:	e8 ec f5 ff ff       	call   f0100fd4 <page_insert>
f01019e8:	83 c4 10             	add    $0x10,%esp
f01019eb:	85 c0                	test   %eax,%eax
f01019ed:	74 19                	je     f0101a08 <mem_init+0x9c2>
f01019ef:	68 14 3f 10 f0       	push   $0xf0103f14
f01019f4:	68 12 43 10 f0       	push   $0xf0104312
f01019f9:	68 1a 03 00 00       	push   $0x31a
f01019fe:	68 ec 42 10 f0       	push   $0xf01042ec
f0101a03:	e8 b4 e6 ff ff       	call   f01000bc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a08:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101a0e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a13:	89 f8                	mov    %edi,%eax
f0101a15:	e8 a0 ef ff ff       	call   f01009ba <check_va2pa>
f0101a1a:	89 da                	mov    %ebx,%edx
f0101a1c:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101a22:	c1 fa 03             	sar    $0x3,%edx
f0101a25:	c1 e2 0c             	shl    $0xc,%edx
f0101a28:	39 d0                	cmp    %edx,%eax
f0101a2a:	74 19                	je     f0101a45 <mem_init+0x9ff>
f0101a2c:	68 a4 3e 10 f0       	push   $0xf0103ea4
f0101a31:	68 12 43 10 f0       	push   $0xf0104312
f0101a36:	68 1b 03 00 00       	push   $0x31b
f0101a3b:	68 ec 42 10 f0       	push   $0xf01042ec
f0101a40:	e8 77 e6 ff ff       	call   f01000bc <_panic>
	assert(pp2->pp_ref == 1);
f0101a45:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a4a:	74 19                	je     f0101a65 <mem_init+0xa1f>
f0101a4c:	68 ec 44 10 f0       	push   $0xf01044ec
f0101a51:	68 12 43 10 f0       	push   $0xf0104312
f0101a56:	68 1c 03 00 00       	push   $0x31c
f0101a5b:	68 ec 42 10 f0       	push   $0xf01042ec
f0101a60:	e8 57 e6 ff ff       	call   f01000bc <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a65:	83 ec 04             	sub    $0x4,%esp
f0101a68:	6a 00                	push   $0x0
f0101a6a:	68 00 10 00 00       	push   $0x1000
f0101a6f:	57                   	push   %edi
f0101a70:	e8 cf f3 ff ff       	call   f0100e44 <pgdir_walk>
f0101a75:	83 c4 10             	add    $0x10,%esp
f0101a78:	f6 00 04             	testb  $0x4,(%eax)
f0101a7b:	75 19                	jne    f0101a96 <mem_init+0xa50>
f0101a7d:	68 54 3f 10 f0       	push   $0xf0103f54
f0101a82:	68 12 43 10 f0       	push   $0xf0104312
f0101a87:	68 1d 03 00 00       	push   $0x31d
f0101a8c:	68 ec 42 10 f0       	push   $0xf01042ec
f0101a91:	e8 26 e6 ff ff       	call   f01000bc <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a96:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101a9b:	f6 00 04             	testb  $0x4,(%eax)
f0101a9e:	75 19                	jne    f0101ab9 <mem_init+0xa73>
f0101aa0:	68 fd 44 10 f0       	push   $0xf01044fd
f0101aa5:	68 12 43 10 f0       	push   $0xf0104312
f0101aaa:	68 1e 03 00 00       	push   $0x31e
f0101aaf:	68 ec 42 10 f0       	push   $0xf01042ec
f0101ab4:	e8 03 e6 ff ff       	call   f01000bc <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ab9:	6a 02                	push   $0x2
f0101abb:	68 00 10 00 00       	push   $0x1000
f0101ac0:	53                   	push   %ebx
f0101ac1:	50                   	push   %eax
f0101ac2:	e8 0d f5 ff ff       	call   f0100fd4 <page_insert>
f0101ac7:	83 c4 10             	add    $0x10,%esp
f0101aca:	85 c0                	test   %eax,%eax
f0101acc:	74 19                	je     f0101ae7 <mem_init+0xaa1>
f0101ace:	68 68 3e 10 f0       	push   $0xf0103e68
f0101ad3:	68 12 43 10 f0       	push   $0xf0104312
f0101ad8:	68 21 03 00 00       	push   $0x321
f0101add:	68 ec 42 10 f0       	push   $0xf01042ec
f0101ae2:	e8 d5 e5 ff ff       	call   f01000bc <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ae7:	83 ec 04             	sub    $0x4,%esp
f0101aea:	6a 00                	push   $0x0
f0101aec:	68 00 10 00 00       	push   $0x1000
f0101af1:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101af7:	e8 48 f3 ff ff       	call   f0100e44 <pgdir_walk>
f0101afc:	83 c4 10             	add    $0x10,%esp
f0101aff:	f6 00 02             	testb  $0x2,(%eax)
f0101b02:	75 19                	jne    f0101b1d <mem_init+0xad7>
f0101b04:	68 88 3f 10 f0       	push   $0xf0103f88
f0101b09:	68 12 43 10 f0       	push   $0xf0104312
f0101b0e:	68 22 03 00 00       	push   $0x322
f0101b13:	68 ec 42 10 f0       	push   $0xf01042ec
f0101b18:	e8 9f e5 ff ff       	call   f01000bc <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b1d:	83 ec 04             	sub    $0x4,%esp
f0101b20:	6a 00                	push   $0x0
f0101b22:	68 00 10 00 00       	push   $0x1000
f0101b27:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b2d:	e8 12 f3 ff ff       	call   f0100e44 <pgdir_walk>
f0101b32:	83 c4 10             	add    $0x10,%esp
f0101b35:	f6 00 04             	testb  $0x4,(%eax)
f0101b38:	74 19                	je     f0101b53 <mem_init+0xb0d>
f0101b3a:	68 bc 3f 10 f0       	push   $0xf0103fbc
f0101b3f:	68 12 43 10 f0       	push   $0xf0104312
f0101b44:	68 23 03 00 00       	push   $0x323
f0101b49:	68 ec 42 10 f0       	push   $0xf01042ec
f0101b4e:	e8 69 e5 ff ff       	call   f01000bc <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b53:	6a 02                	push   $0x2
f0101b55:	68 00 00 40 00       	push   $0x400000
f0101b5a:	56                   	push   %esi
f0101b5b:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b61:	e8 6e f4 ff ff       	call   f0100fd4 <page_insert>
f0101b66:	83 c4 10             	add    $0x10,%esp
f0101b69:	85 c0                	test   %eax,%eax
f0101b6b:	78 19                	js     f0101b86 <mem_init+0xb40>
f0101b6d:	68 f4 3f 10 f0       	push   $0xf0103ff4
f0101b72:	68 12 43 10 f0       	push   $0xf0104312
f0101b77:	68 26 03 00 00       	push   $0x326
f0101b7c:	68 ec 42 10 f0       	push   $0xf01042ec
f0101b81:	e8 36 e5 ff ff       	call   f01000bc <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b86:	6a 02                	push   $0x2
f0101b88:	68 00 10 00 00       	push   $0x1000
f0101b8d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b90:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b96:	e8 39 f4 ff ff       	call   f0100fd4 <page_insert>
f0101b9b:	83 c4 10             	add    $0x10,%esp
f0101b9e:	85 c0                	test   %eax,%eax
f0101ba0:	74 19                	je     f0101bbb <mem_init+0xb75>
f0101ba2:	68 2c 40 10 f0       	push   $0xf010402c
f0101ba7:	68 12 43 10 f0       	push   $0xf0104312
f0101bac:	68 29 03 00 00       	push   $0x329
f0101bb1:	68 ec 42 10 f0       	push   $0xf01042ec
f0101bb6:	e8 01 e5 ff ff       	call   f01000bc <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bbb:	83 ec 04             	sub    $0x4,%esp
f0101bbe:	6a 00                	push   $0x0
f0101bc0:	68 00 10 00 00       	push   $0x1000
f0101bc5:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101bcb:	e8 74 f2 ff ff       	call   f0100e44 <pgdir_walk>
f0101bd0:	83 c4 10             	add    $0x10,%esp
f0101bd3:	f6 00 04             	testb  $0x4,(%eax)
f0101bd6:	74 19                	je     f0101bf1 <mem_init+0xbab>
f0101bd8:	68 bc 3f 10 f0       	push   $0xf0103fbc
f0101bdd:	68 12 43 10 f0       	push   $0xf0104312
f0101be2:	68 2a 03 00 00       	push   $0x32a
f0101be7:	68 ec 42 10 f0       	push   $0xf01042ec
f0101bec:	e8 cb e4 ff ff       	call   f01000bc <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bf1:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101bf7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bfc:	89 f8                	mov    %edi,%eax
f0101bfe:	e8 b7 ed ff ff       	call   f01009ba <check_va2pa>
f0101c03:	89 c1                	mov    %eax,%ecx
f0101c05:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c0b:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101c11:	c1 f8 03             	sar    $0x3,%eax
f0101c14:	c1 e0 0c             	shl    $0xc,%eax
f0101c17:	39 c1                	cmp    %eax,%ecx
f0101c19:	74 19                	je     f0101c34 <mem_init+0xbee>
f0101c1b:	68 68 40 10 f0       	push   $0xf0104068
f0101c20:	68 12 43 10 f0       	push   $0xf0104312
f0101c25:	68 2d 03 00 00       	push   $0x32d
f0101c2a:	68 ec 42 10 f0       	push   $0xf01042ec
f0101c2f:	e8 88 e4 ff ff       	call   f01000bc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c34:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c39:	89 f8                	mov    %edi,%eax
f0101c3b:	e8 7a ed ff ff       	call   f01009ba <check_va2pa>
f0101c40:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c43:	74 19                	je     f0101c5e <mem_init+0xc18>
f0101c45:	68 94 40 10 f0       	push   $0xf0104094
f0101c4a:	68 12 43 10 f0       	push   $0xf0104312
f0101c4f:	68 2e 03 00 00       	push   $0x32e
f0101c54:	68 ec 42 10 f0       	push   $0xf01042ec
f0101c59:	e8 5e e4 ff ff       	call   f01000bc <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c61:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101c66:	74 19                	je     f0101c81 <mem_init+0xc3b>
f0101c68:	68 13 45 10 f0       	push   $0xf0104513
f0101c6d:	68 12 43 10 f0       	push   $0xf0104312
f0101c72:	68 30 03 00 00       	push   $0x330
f0101c77:	68 ec 42 10 f0       	push   $0xf01042ec
f0101c7c:	e8 3b e4 ff ff       	call   f01000bc <_panic>
	assert(pp2->pp_ref == 0);
f0101c81:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c86:	74 19                	je     f0101ca1 <mem_init+0xc5b>
f0101c88:	68 24 45 10 f0       	push   $0xf0104524
f0101c8d:	68 12 43 10 f0       	push   $0xf0104312
f0101c92:	68 31 03 00 00       	push   $0x331
f0101c97:	68 ec 42 10 f0       	push   $0xf01042ec
f0101c9c:	e8 1b e4 ff ff       	call   f01000bc <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ca1:	83 ec 0c             	sub    $0xc,%esp
f0101ca4:	6a 00                	push   $0x0
f0101ca6:	e8 ca f0 ff ff       	call   f0100d75 <page_alloc>
f0101cab:	83 c4 10             	add    $0x10,%esp
f0101cae:	85 c0                	test   %eax,%eax
f0101cb0:	74 04                	je     f0101cb6 <mem_init+0xc70>
f0101cb2:	39 c3                	cmp    %eax,%ebx
f0101cb4:	74 19                	je     f0101ccf <mem_init+0xc89>
f0101cb6:	68 c4 40 10 f0       	push   $0xf01040c4
f0101cbb:	68 12 43 10 f0       	push   $0xf0104312
f0101cc0:	68 34 03 00 00       	push   $0x334
f0101cc5:	68 ec 42 10 f0       	push   $0xf01042ec
f0101cca:	e8 ed e3 ff ff       	call   f01000bc <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ccf:	83 ec 08             	sub    $0x8,%esp
f0101cd2:	6a 00                	push   $0x0
f0101cd4:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101cda:	e8 ba f2 ff ff       	call   f0100f99 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cdf:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101ce5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cea:	89 f8                	mov    %edi,%eax
f0101cec:	e8 c9 ec ff ff       	call   f01009ba <check_va2pa>
f0101cf1:	83 c4 10             	add    $0x10,%esp
f0101cf4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cf7:	74 19                	je     f0101d12 <mem_init+0xccc>
f0101cf9:	68 e8 40 10 f0       	push   $0xf01040e8
f0101cfe:	68 12 43 10 f0       	push   $0xf0104312
f0101d03:	68 38 03 00 00       	push   $0x338
f0101d08:	68 ec 42 10 f0       	push   $0xf01042ec
f0101d0d:	e8 aa e3 ff ff       	call   f01000bc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d12:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d17:	89 f8                	mov    %edi,%eax
f0101d19:	e8 9c ec ff ff       	call   f01009ba <check_va2pa>
f0101d1e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d21:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101d27:	c1 fa 03             	sar    $0x3,%edx
f0101d2a:	c1 e2 0c             	shl    $0xc,%edx
f0101d2d:	39 d0                	cmp    %edx,%eax
f0101d2f:	74 19                	je     f0101d4a <mem_init+0xd04>
f0101d31:	68 94 40 10 f0       	push   $0xf0104094
f0101d36:	68 12 43 10 f0       	push   $0xf0104312
f0101d3b:	68 39 03 00 00       	push   $0x339
f0101d40:	68 ec 42 10 f0       	push   $0xf01042ec
f0101d45:	e8 72 e3 ff ff       	call   f01000bc <_panic>
	assert(pp1->pp_ref == 1);
f0101d4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d4d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d52:	74 19                	je     f0101d6d <mem_init+0xd27>
f0101d54:	68 ca 44 10 f0       	push   $0xf01044ca
f0101d59:	68 12 43 10 f0       	push   $0xf0104312
f0101d5e:	68 3a 03 00 00       	push   $0x33a
f0101d63:	68 ec 42 10 f0       	push   $0xf01042ec
f0101d68:	e8 4f e3 ff ff       	call   f01000bc <_panic>
	assert(pp2->pp_ref == 0);
f0101d6d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d72:	74 19                	je     f0101d8d <mem_init+0xd47>
f0101d74:	68 24 45 10 f0       	push   $0xf0104524
f0101d79:	68 12 43 10 f0       	push   $0xf0104312
f0101d7e:	68 3b 03 00 00       	push   $0x33b
f0101d83:	68 ec 42 10 f0       	push   $0xf01042ec
f0101d88:	e8 2f e3 ff ff       	call   f01000bc <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d8d:	83 ec 08             	sub    $0x8,%esp
f0101d90:	68 00 10 00 00       	push   $0x1000
f0101d95:	57                   	push   %edi
f0101d96:	e8 fe f1 ff ff       	call   f0100f99 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d9b:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101da1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101da6:	89 f8                	mov    %edi,%eax
f0101da8:	e8 0d ec ff ff       	call   f01009ba <check_va2pa>
f0101dad:	83 c4 10             	add    $0x10,%esp
f0101db0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101db3:	74 19                	je     f0101dce <mem_init+0xd88>
f0101db5:	68 e8 40 10 f0       	push   $0xf01040e8
f0101dba:	68 12 43 10 f0       	push   $0xf0104312
f0101dbf:	68 3f 03 00 00       	push   $0x33f
f0101dc4:	68 ec 42 10 f0       	push   $0xf01042ec
f0101dc9:	e8 ee e2 ff ff       	call   f01000bc <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101dce:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dd3:	89 f8                	mov    %edi,%eax
f0101dd5:	e8 e0 eb ff ff       	call   f01009ba <check_va2pa>
f0101dda:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ddd:	74 19                	je     f0101df8 <mem_init+0xdb2>
f0101ddf:	68 0c 41 10 f0       	push   $0xf010410c
f0101de4:	68 12 43 10 f0       	push   $0xf0104312
f0101de9:	68 40 03 00 00       	push   $0x340
f0101dee:	68 ec 42 10 f0       	push   $0xf01042ec
f0101df3:	e8 c4 e2 ff ff       	call   f01000bc <_panic>
	assert(pp1->pp_ref == 0);
f0101df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dfb:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e00:	74 19                	je     f0101e1b <mem_init+0xdd5>
f0101e02:	68 35 45 10 f0       	push   $0xf0104535
f0101e07:	68 12 43 10 f0       	push   $0xf0104312
f0101e0c:	68 41 03 00 00       	push   $0x341
f0101e11:	68 ec 42 10 f0       	push   $0xf01042ec
f0101e16:	e8 a1 e2 ff ff       	call   f01000bc <_panic>
	assert(pp2->pp_ref == 0);
f0101e1b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e20:	74 19                	je     f0101e3b <mem_init+0xdf5>
f0101e22:	68 24 45 10 f0       	push   $0xf0104524
f0101e27:	68 12 43 10 f0       	push   $0xf0104312
f0101e2c:	68 42 03 00 00       	push   $0x342
f0101e31:	68 ec 42 10 f0       	push   $0xf01042ec
f0101e36:	e8 81 e2 ff ff       	call   f01000bc <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e3b:	83 ec 0c             	sub    $0xc,%esp
f0101e3e:	6a 00                	push   $0x0
f0101e40:	e8 30 ef ff ff       	call   f0100d75 <page_alloc>
f0101e45:	83 c4 10             	add    $0x10,%esp
f0101e48:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e4b:	75 04                	jne    f0101e51 <mem_init+0xe0b>
f0101e4d:	85 c0                	test   %eax,%eax
f0101e4f:	75 19                	jne    f0101e6a <mem_init+0xe24>
f0101e51:	68 34 41 10 f0       	push   $0xf0104134
f0101e56:	68 12 43 10 f0       	push   $0xf0104312
f0101e5b:	68 45 03 00 00       	push   $0x345
f0101e60:	68 ec 42 10 f0       	push   $0xf01042ec
f0101e65:	e8 52 e2 ff ff       	call   f01000bc <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e6a:	83 ec 0c             	sub    $0xc,%esp
f0101e6d:	6a 00                	push   $0x0
f0101e6f:	e8 01 ef ff ff       	call   f0100d75 <page_alloc>
f0101e74:	83 c4 10             	add    $0x10,%esp
f0101e77:	85 c0                	test   %eax,%eax
f0101e79:	74 19                	je     f0101e94 <mem_init+0xe4e>
f0101e7b:	68 78 44 10 f0       	push   $0xf0104478
f0101e80:	68 12 43 10 f0       	push   $0xf0104312
f0101e85:	68 48 03 00 00       	push   $0x348
f0101e8a:	68 ec 42 10 f0       	push   $0xf01042ec
f0101e8f:	e8 28 e2 ff ff       	call   f01000bc <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e94:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f0101e9a:	8b 11                	mov    (%ecx),%edx
f0101e9c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ea2:	89 f0                	mov    %esi,%eax
f0101ea4:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101eaa:	c1 f8 03             	sar    $0x3,%eax
f0101ead:	c1 e0 0c             	shl    $0xc,%eax
f0101eb0:	39 c2                	cmp    %eax,%edx
f0101eb2:	74 19                	je     f0101ecd <mem_init+0xe87>
f0101eb4:	68 10 3e 10 f0       	push   $0xf0103e10
f0101eb9:	68 12 43 10 f0       	push   $0xf0104312
f0101ebe:	68 4b 03 00 00       	push   $0x34b
f0101ec3:	68 ec 42 10 f0       	push   $0xf01042ec
f0101ec8:	e8 ef e1 ff ff       	call   f01000bc <_panic>
	kern_pgdir[0] = 0;
f0101ecd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ed3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ed8:	74 19                	je     f0101ef3 <mem_init+0xead>
f0101eda:	68 db 44 10 f0       	push   $0xf01044db
f0101edf:	68 12 43 10 f0       	push   $0xf0104312
f0101ee4:	68 4d 03 00 00       	push   $0x34d
f0101ee9:	68 ec 42 10 f0       	push   $0xf01042ec
f0101eee:	e8 c9 e1 ff ff       	call   f01000bc <_panic>
	pp0->pp_ref = 0;
f0101ef3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ef9:	83 ec 0c             	sub    $0xc,%esp
f0101efc:	56                   	push   %esi
f0101efd:	e8 e3 ee ff ff       	call   f0100de5 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f02:	83 c4 0c             	add    $0xc,%esp
f0101f05:	6a 01                	push   $0x1
f0101f07:	68 00 10 40 00       	push   $0x401000
f0101f0c:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101f12:	e8 2d ef ff ff       	call   f0100e44 <pgdir_walk>
f0101f17:	89 c7                	mov    %eax,%edi
f0101f19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f1c:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101f21:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f24:	8b 40 04             	mov    0x4(%eax),%eax
f0101f27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f2c:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0101f32:	89 c2                	mov    %eax,%edx
f0101f34:	c1 ea 0c             	shr    $0xc,%edx
f0101f37:	83 c4 10             	add    $0x10,%esp
f0101f3a:	39 ca                	cmp    %ecx,%edx
f0101f3c:	72 15                	jb     f0101f53 <mem_init+0xf0d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f3e:	50                   	push   %eax
f0101f3f:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0101f44:	68 54 03 00 00       	push   $0x354
f0101f49:	68 ec 42 10 f0       	push   $0xf01042ec
f0101f4e:	e8 69 e1 ff ff       	call   f01000bc <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101f53:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101f58:	39 c7                	cmp    %eax,%edi
f0101f5a:	74 19                	je     f0101f75 <mem_init+0xf2f>
f0101f5c:	68 46 45 10 f0       	push   $0xf0104546
f0101f61:	68 12 43 10 f0       	push   $0xf0104312
f0101f66:	68 55 03 00 00       	push   $0x355
f0101f6b:	68 ec 42 10 f0       	push   $0xf01042ec
f0101f70:	e8 47 e1 ff ff       	call   f01000bc <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f75:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f78:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101f7f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f85:	89 f0                	mov    %esi,%eax
f0101f87:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101f8d:	c1 f8 03             	sar    $0x3,%eax
f0101f90:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f93:	89 c2                	mov    %eax,%edx
f0101f95:	c1 ea 0c             	shr    $0xc,%edx
f0101f98:	39 d1                	cmp    %edx,%ecx
f0101f9a:	77 12                	ja     f0101fae <mem_init+0xf68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f9c:	50                   	push   %eax
f0101f9d:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0101fa2:	6a 52                	push   $0x52
f0101fa4:	68 f8 42 10 f0       	push   $0xf01042f8
f0101fa9:	e8 0e e1 ff ff       	call   f01000bc <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fae:	83 ec 04             	sub    $0x4,%esp
f0101fb1:	68 00 10 00 00       	push   $0x1000
f0101fb6:	68 ff 00 00 00       	push   $0xff
f0101fbb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fc0:	50                   	push   %eax
f0101fc1:	e8 c3 11 00 00       	call   f0103189 <memset>
	page_free(pp0);
f0101fc6:	89 34 24             	mov    %esi,(%esp)
f0101fc9:	e8 17 ee ff ff       	call   f0100de5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101fce:	83 c4 0c             	add    $0xc,%esp
f0101fd1:	6a 01                	push   $0x1
f0101fd3:	6a 00                	push   $0x0
f0101fd5:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101fdb:	e8 64 ee ff ff       	call   f0100e44 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fe0:	89 f2                	mov    %esi,%edx
f0101fe2:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101fe8:	c1 fa 03             	sar    $0x3,%edx
f0101feb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fee:	89 d0                	mov    %edx,%eax
f0101ff0:	c1 e8 0c             	shr    $0xc,%eax
f0101ff3:	83 c4 10             	add    $0x10,%esp
f0101ff6:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0101ffc:	72 12                	jb     f0102010 <mem_init+0xfca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ffe:	52                   	push   %edx
f0101fff:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0102004:	6a 52                	push   $0x52
f0102006:	68 f8 42 10 f0       	push   $0xf01042f8
f010200b:	e8 ac e0 ff ff       	call   f01000bc <_panic>
	return (void *)(pa + KERNBASE);
f0102010:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102016:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102019:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010201f:	f6 00 01             	testb  $0x1,(%eax)
f0102022:	74 19                	je     f010203d <mem_init+0xff7>
f0102024:	68 5e 45 10 f0       	push   $0xf010455e
f0102029:	68 12 43 10 f0       	push   $0xf0104312
f010202e:	68 5f 03 00 00       	push   $0x35f
f0102033:	68 ec 42 10 f0       	push   $0xf01042ec
f0102038:	e8 7f e0 ff ff       	call   f01000bc <_panic>
f010203d:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102040:	39 d0                	cmp    %edx,%eax
f0102042:	75 db                	jne    f010201f <mem_init+0xfd9>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102044:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0102049:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010204f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102055:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102058:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f010205d:	83 ec 0c             	sub    $0xc,%esp
f0102060:	56                   	push   %esi
f0102061:	e8 7f ed ff ff       	call   f0100de5 <page_free>
	page_free(pp1);
f0102066:	83 c4 04             	add    $0x4,%esp
f0102069:	ff 75 d4             	pushl  -0x2c(%ebp)
f010206c:	e8 74 ed ff ff       	call   f0100de5 <page_free>
	page_free(pp2);
f0102071:	89 1c 24             	mov    %ebx,(%esp)
f0102074:	e8 6c ed ff ff       	call   f0100de5 <page_free>

	cprintf("check_page() succeeded!\n");
f0102079:	c7 04 24 75 45 10 f0 	movl   $0xf0104575,(%esp)
f0102080:	e8 4b 06 00 00       	call   f01026d0 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102085:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010208a:	83 c4 10             	add    $0x10,%esp
f010208d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102092:	77 15                	ja     f01020a9 <mem_init+0x1063>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102094:	50                   	push   %eax
f0102095:	68 14 3d 10 f0       	push   $0xf0103d14
f010209a:	68 b1 00 00 00       	push   $0xb1
f010209f:	68 ec 42 10 f0       	push   $0xf01042ec
f01020a4:	e8 13 e0 ff ff       	call   f01000bc <_panic>
f01020a9:	83 ec 08             	sub    $0x8,%esp
f01020ac:	6a 05                	push   $0x5
f01020ae:	05 00 00 00 10       	add    $0x10000000,%eax
f01020b3:	50                   	push   %eax
f01020b4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020b9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020be:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01020c3:	e8 1f ee ff ff       	call   f0100ee7 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020c8:	83 c4 10             	add    $0x10,%esp
f01020cb:	b8 00 c0 10 f0       	mov    $0xf010c000,%eax
f01020d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020d5:	77 15                	ja     f01020ec <mem_init+0x10a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020d7:	50                   	push   %eax
f01020d8:	68 14 3d 10 f0       	push   $0xf0103d14
f01020dd:	68 bd 00 00 00       	push   $0xbd
f01020e2:	68 ec 42 10 f0       	push   $0xf01042ec
f01020e7:	e8 d0 df ff ff       	call   f01000bc <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01020ec:	83 ec 08             	sub    $0x8,%esp
f01020ef:	6a 03                	push   $0x3
f01020f1:	68 00 c0 10 00       	push   $0x10c000
f01020f6:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020fb:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102100:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0102105:	e8 dd ed ff ff       	call   f0100ee7 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W | PTE_P);
f010210a:	83 c4 08             	add    $0x8,%esp
f010210d:	6a 03                	push   $0x3
f010210f:	6a 00                	push   $0x0
f0102111:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102116:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010211b:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0102120:	e8 c2 ed ff ff       	call   f0100ee7 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102125:	8b 35 68 69 11 f0    	mov    0xf0116968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010212b:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0102130:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102133:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010213a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010213f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102142:	8b 3d 6c 69 11 f0    	mov    0xf011696c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102148:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010214b:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010214e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102153:	eb 55                	jmp    f01021aa <mem_init+0x1164>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102155:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010215b:	89 f0                	mov    %esi,%eax
f010215d:	e8 58 e8 ff ff       	call   f01009ba <check_va2pa>
f0102162:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102169:	77 15                	ja     f0102180 <mem_init+0x113a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010216b:	57                   	push   %edi
f010216c:	68 14 3d 10 f0       	push   $0xf0103d14
f0102171:	68 a6 02 00 00       	push   $0x2a6
f0102176:	68 ec 42 10 f0       	push   $0xf01042ec
f010217b:	e8 3c df ff ff       	call   f01000bc <_panic>
f0102180:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f0102187:	39 c2                	cmp    %eax,%edx
f0102189:	74 19                	je     f01021a4 <mem_init+0x115e>
f010218b:	68 58 41 10 f0       	push   $0xf0104158
f0102190:	68 12 43 10 f0       	push   $0xf0104312
f0102195:	68 a6 02 00 00       	push   $0x2a6
f010219a:	68 ec 42 10 f0       	push   $0xf01042ec
f010219f:	e8 18 df ff ff       	call   f01000bc <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021aa:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01021ad:	77 a6                	ja     f0102155 <mem_init+0x110f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01021af:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01021b2:	c1 e7 0c             	shl    $0xc,%edi
f01021b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021ba:	eb 30                	jmp    f01021ec <mem_init+0x11a6>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01021bc:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01021c2:	89 f0                	mov    %esi,%eax
f01021c4:	e8 f1 e7 ff ff       	call   f01009ba <check_va2pa>
f01021c9:	39 c3                	cmp    %eax,%ebx
f01021cb:	74 19                	je     f01021e6 <mem_init+0x11a0>
f01021cd:	68 8c 41 10 f0       	push   $0xf010418c
f01021d2:	68 12 43 10 f0       	push   $0xf0104312
f01021d7:	68 ab 02 00 00       	push   $0x2ab
f01021dc:	68 ec 42 10 f0       	push   $0xf01042ec
f01021e1:	e8 d6 de ff ff       	call   f01000bc <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01021e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021ec:	39 fb                	cmp    %edi,%ebx
f01021ee:	72 cc                	jb     f01021bc <mem_init+0x1176>
f01021f0:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01021f5:	89 da                	mov    %ebx,%edx
f01021f7:	89 f0                	mov    %esi,%eax
f01021f9:	e8 bc e7 ff ff       	call   f01009ba <check_va2pa>
f01021fe:	8d 93 00 40 11 10    	lea    0x10114000(%ebx),%edx
f0102204:	39 c2                	cmp    %eax,%edx
f0102206:	74 19                	je     f0102221 <mem_init+0x11db>
f0102208:	68 b4 41 10 f0       	push   $0xf01041b4
f010220d:	68 12 43 10 f0       	push   $0xf0104312
f0102212:	68 af 02 00 00       	push   $0x2af
f0102217:	68 ec 42 10 f0       	push   $0xf01042ec
f010221c:	e8 9b de ff ff       	call   f01000bc <_panic>
f0102221:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102227:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010222d:	75 c6                	jne    f01021f5 <mem_init+0x11af>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010222f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102234:	89 f0                	mov    %esi,%eax
f0102236:	e8 7f e7 ff ff       	call   f01009ba <check_va2pa>
f010223b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010223e:	74 51                	je     f0102291 <mem_init+0x124b>
f0102240:	68 fc 41 10 f0       	push   $0xf01041fc
f0102245:	68 12 43 10 f0       	push   $0xf0104312
f010224a:	68 b0 02 00 00       	push   $0x2b0
f010224f:	68 ec 42 10 f0       	push   $0xf01042ec
f0102254:	e8 63 de ff ff       	call   f01000bc <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102259:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010225e:	72 36                	jb     f0102296 <mem_init+0x1250>
f0102260:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102265:	76 07                	jbe    f010226e <mem_init+0x1228>
f0102267:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010226c:	75 28                	jne    f0102296 <mem_init+0x1250>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010226e:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102272:	0f 85 83 00 00 00    	jne    f01022fb <mem_init+0x12b5>
f0102278:	68 8e 45 10 f0       	push   $0xf010458e
f010227d:	68 12 43 10 f0       	push   $0xf0104312
f0102282:	68 b8 02 00 00       	push   $0x2b8
f0102287:	68 ec 42 10 f0       	push   $0xf01042ec
f010228c:	e8 2b de ff ff       	call   f01000bc <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102291:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102296:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010229b:	76 3f                	jbe    f01022dc <mem_init+0x1296>
				assert(pgdir[i] & PTE_P);
f010229d:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01022a0:	f6 c2 01             	test   $0x1,%dl
f01022a3:	75 19                	jne    f01022be <mem_init+0x1278>
f01022a5:	68 8e 45 10 f0       	push   $0xf010458e
f01022aa:	68 12 43 10 f0       	push   $0xf0104312
f01022af:	68 bc 02 00 00       	push   $0x2bc
f01022b4:	68 ec 42 10 f0       	push   $0xf01042ec
f01022b9:	e8 fe dd ff ff       	call   f01000bc <_panic>
				assert(pgdir[i] & PTE_W);
f01022be:	f6 c2 02             	test   $0x2,%dl
f01022c1:	75 38                	jne    f01022fb <mem_init+0x12b5>
f01022c3:	68 9f 45 10 f0       	push   $0xf010459f
f01022c8:	68 12 43 10 f0       	push   $0xf0104312
f01022cd:	68 bd 02 00 00       	push   $0x2bd
f01022d2:	68 ec 42 10 f0       	push   $0xf01042ec
f01022d7:	e8 e0 dd ff ff       	call   f01000bc <_panic>
			} else
				assert(pgdir[i] == 0);
f01022dc:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01022e0:	74 19                	je     f01022fb <mem_init+0x12b5>
f01022e2:	68 b0 45 10 f0       	push   $0xf01045b0
f01022e7:	68 12 43 10 f0       	push   $0xf0104312
f01022ec:	68 bf 02 00 00       	push   $0x2bf
f01022f1:	68 ec 42 10 f0       	push   $0xf01042ec
f01022f6:	e8 c1 dd ff ff       	call   f01000bc <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01022fb:	83 c0 01             	add    $0x1,%eax
f01022fe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102303:	0f 86 50 ff ff ff    	jbe    f0102259 <mem_init+0x1213>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102309:	83 ec 0c             	sub    $0xc,%esp
f010230c:	68 2c 42 10 f0       	push   $0xf010422c
f0102311:	e8 ba 03 00 00       	call   f01026d0 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102316:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010231b:	83 c4 10             	add    $0x10,%esp
f010231e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102323:	77 15                	ja     f010233a <mem_init+0x12f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102325:	50                   	push   %eax
f0102326:	68 14 3d 10 f0       	push   $0xf0103d14
f010232b:	68 d5 00 00 00       	push   $0xd5
f0102330:	68 ec 42 10 f0       	push   $0xf01042ec
f0102335:	e8 82 dd ff ff       	call   f01000bc <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010233a:	05 00 00 00 10       	add    $0x10000000,%eax
f010233f:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102342:	b8 00 00 00 00       	mov    $0x0,%eax
f0102347:	e8 d2 e6 ff ff       	call   f0100a1e <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010234c:	0f 20 c0             	mov    %cr0,%eax
f010234f:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102352:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102357:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010235a:	83 ec 0c             	sub    $0xc,%esp
f010235d:	6a 00                	push   $0x0
f010235f:	e8 11 ea ff ff       	call   f0100d75 <page_alloc>
f0102364:	89 c3                	mov    %eax,%ebx
f0102366:	83 c4 10             	add    $0x10,%esp
f0102369:	85 c0                	test   %eax,%eax
f010236b:	75 19                	jne    f0102386 <mem_init+0x1340>
f010236d:	68 cd 43 10 f0       	push   $0xf01043cd
f0102372:	68 12 43 10 f0       	push   $0xf0104312
f0102377:	68 7a 03 00 00       	push   $0x37a
f010237c:	68 ec 42 10 f0       	push   $0xf01042ec
f0102381:	e8 36 dd ff ff       	call   f01000bc <_panic>
	assert((pp1 = page_alloc(0)));
f0102386:	83 ec 0c             	sub    $0xc,%esp
f0102389:	6a 00                	push   $0x0
f010238b:	e8 e5 e9 ff ff       	call   f0100d75 <page_alloc>
f0102390:	89 c7                	mov    %eax,%edi
f0102392:	83 c4 10             	add    $0x10,%esp
f0102395:	85 c0                	test   %eax,%eax
f0102397:	75 19                	jne    f01023b2 <mem_init+0x136c>
f0102399:	68 e3 43 10 f0       	push   $0xf01043e3
f010239e:	68 12 43 10 f0       	push   $0xf0104312
f01023a3:	68 7b 03 00 00       	push   $0x37b
f01023a8:	68 ec 42 10 f0       	push   $0xf01042ec
f01023ad:	e8 0a dd ff ff       	call   f01000bc <_panic>
	assert((pp2 = page_alloc(0)));
f01023b2:	83 ec 0c             	sub    $0xc,%esp
f01023b5:	6a 00                	push   $0x0
f01023b7:	e8 b9 e9 ff ff       	call   f0100d75 <page_alloc>
f01023bc:	89 c6                	mov    %eax,%esi
f01023be:	83 c4 10             	add    $0x10,%esp
f01023c1:	85 c0                	test   %eax,%eax
f01023c3:	75 19                	jne    f01023de <mem_init+0x1398>
f01023c5:	68 f9 43 10 f0       	push   $0xf01043f9
f01023ca:	68 12 43 10 f0       	push   $0xf0104312
f01023cf:	68 7c 03 00 00       	push   $0x37c
f01023d4:	68 ec 42 10 f0       	push   $0xf01042ec
f01023d9:	e8 de dc ff ff       	call   f01000bc <_panic>
	page_free(pp0);
f01023de:	83 ec 0c             	sub    $0xc,%esp
f01023e1:	53                   	push   %ebx
f01023e2:	e8 fe e9 ff ff       	call   f0100de5 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023e7:	89 f8                	mov    %edi,%eax
f01023e9:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01023ef:	c1 f8 03             	sar    $0x3,%eax
f01023f2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023f5:	89 c2                	mov    %eax,%edx
f01023f7:	c1 ea 0c             	shr    $0xc,%edx
f01023fa:	83 c4 10             	add    $0x10,%esp
f01023fd:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0102403:	72 12                	jb     f0102417 <mem_init+0x13d1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102405:	50                   	push   %eax
f0102406:	68 d0 3b 10 f0       	push   $0xf0103bd0
f010240b:	6a 52                	push   $0x52
f010240d:	68 f8 42 10 f0       	push   $0xf01042f8
f0102412:	e8 a5 dc ff ff       	call   f01000bc <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102417:	83 ec 04             	sub    $0x4,%esp
f010241a:	68 00 10 00 00       	push   $0x1000
f010241f:	6a 01                	push   $0x1
f0102421:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102426:	50                   	push   %eax
f0102427:	e8 5d 0d 00 00       	call   f0103189 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010242c:	89 f0                	mov    %esi,%eax
f010242e:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0102434:	c1 f8 03             	sar    $0x3,%eax
f0102437:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010243a:	89 c2                	mov    %eax,%edx
f010243c:	c1 ea 0c             	shr    $0xc,%edx
f010243f:	83 c4 10             	add    $0x10,%esp
f0102442:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0102448:	72 12                	jb     f010245c <mem_init+0x1416>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010244a:	50                   	push   %eax
f010244b:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0102450:	6a 52                	push   $0x52
f0102452:	68 f8 42 10 f0       	push   $0xf01042f8
f0102457:	e8 60 dc ff ff       	call   f01000bc <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010245c:	83 ec 04             	sub    $0x4,%esp
f010245f:	68 00 10 00 00       	push   $0x1000
f0102464:	6a 02                	push   $0x2
f0102466:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010246b:	50                   	push   %eax
f010246c:	e8 18 0d 00 00       	call   f0103189 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102471:	6a 02                	push   $0x2
f0102473:	68 00 10 00 00       	push   $0x1000
f0102478:	57                   	push   %edi
f0102479:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010247f:	e8 50 eb ff ff       	call   f0100fd4 <page_insert>
	assert(pp1->pp_ref == 1);
f0102484:	83 c4 20             	add    $0x20,%esp
f0102487:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010248c:	74 19                	je     f01024a7 <mem_init+0x1461>
f010248e:	68 ca 44 10 f0       	push   $0xf01044ca
f0102493:	68 12 43 10 f0       	push   $0xf0104312
f0102498:	68 81 03 00 00       	push   $0x381
f010249d:	68 ec 42 10 f0       	push   $0xf01042ec
f01024a2:	e8 15 dc ff ff       	call   f01000bc <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01024a7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01024ae:	01 01 01 
f01024b1:	74 19                	je     f01024cc <mem_init+0x1486>
f01024b3:	68 4c 42 10 f0       	push   $0xf010424c
f01024b8:	68 12 43 10 f0       	push   $0xf0104312
f01024bd:	68 82 03 00 00       	push   $0x382
f01024c2:	68 ec 42 10 f0       	push   $0xf01042ec
f01024c7:	e8 f0 db ff ff       	call   f01000bc <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01024cc:	6a 02                	push   $0x2
f01024ce:	68 00 10 00 00       	push   $0x1000
f01024d3:	56                   	push   %esi
f01024d4:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01024da:	e8 f5 ea ff ff       	call   f0100fd4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024df:	83 c4 10             	add    $0x10,%esp
f01024e2:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01024e9:	02 02 02 
f01024ec:	74 19                	je     f0102507 <mem_init+0x14c1>
f01024ee:	68 70 42 10 f0       	push   $0xf0104270
f01024f3:	68 12 43 10 f0       	push   $0xf0104312
f01024f8:	68 84 03 00 00       	push   $0x384
f01024fd:	68 ec 42 10 f0       	push   $0xf01042ec
f0102502:	e8 b5 db ff ff       	call   f01000bc <_panic>
	assert(pp2->pp_ref == 1);
f0102507:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010250c:	74 19                	je     f0102527 <mem_init+0x14e1>
f010250e:	68 ec 44 10 f0       	push   $0xf01044ec
f0102513:	68 12 43 10 f0       	push   $0xf0104312
f0102518:	68 85 03 00 00       	push   $0x385
f010251d:	68 ec 42 10 f0       	push   $0xf01042ec
f0102522:	e8 95 db ff ff       	call   f01000bc <_panic>
	assert(pp1->pp_ref == 0);
f0102527:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010252c:	74 19                	je     f0102547 <mem_init+0x1501>
f010252e:	68 35 45 10 f0       	push   $0xf0104535
f0102533:	68 12 43 10 f0       	push   $0xf0104312
f0102538:	68 86 03 00 00       	push   $0x386
f010253d:	68 ec 42 10 f0       	push   $0xf01042ec
f0102542:	e8 75 db ff ff       	call   f01000bc <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102547:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010254e:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102551:	89 f0                	mov    %esi,%eax
f0102553:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0102559:	c1 f8 03             	sar    $0x3,%eax
f010255c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010255f:	89 c2                	mov    %eax,%edx
f0102561:	c1 ea 0c             	shr    $0xc,%edx
f0102564:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f010256a:	72 12                	jb     f010257e <mem_init+0x1538>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010256c:	50                   	push   %eax
f010256d:	68 d0 3b 10 f0       	push   $0xf0103bd0
f0102572:	6a 52                	push   $0x52
f0102574:	68 f8 42 10 f0       	push   $0xf01042f8
f0102579:	e8 3e db ff ff       	call   f01000bc <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010257e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102585:	03 03 03 
f0102588:	74 19                	je     f01025a3 <mem_init+0x155d>
f010258a:	68 94 42 10 f0       	push   $0xf0104294
f010258f:	68 12 43 10 f0       	push   $0xf0104312
f0102594:	68 88 03 00 00       	push   $0x388
f0102599:	68 ec 42 10 f0       	push   $0xf01042ec
f010259e:	e8 19 db ff ff       	call   f01000bc <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025a3:	83 ec 08             	sub    $0x8,%esp
f01025a6:	68 00 10 00 00       	push   $0x1000
f01025ab:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01025b1:	e8 e3 e9 ff ff       	call   f0100f99 <page_remove>
	assert(pp2->pp_ref == 0);
f01025b6:	83 c4 10             	add    $0x10,%esp
f01025b9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025be:	74 19                	je     f01025d9 <mem_init+0x1593>
f01025c0:	68 24 45 10 f0       	push   $0xf0104524
f01025c5:	68 12 43 10 f0       	push   $0xf0104312
f01025ca:	68 8a 03 00 00       	push   $0x38a
f01025cf:	68 ec 42 10 f0       	push   $0xf01042ec
f01025d4:	e8 e3 da ff ff       	call   f01000bc <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025d9:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f01025df:	8b 11                	mov    (%ecx),%edx
f01025e1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025e7:	89 d8                	mov    %ebx,%eax
f01025e9:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01025ef:	c1 f8 03             	sar    $0x3,%eax
f01025f2:	c1 e0 0c             	shl    $0xc,%eax
f01025f5:	39 c2                	cmp    %eax,%edx
f01025f7:	74 19                	je     f0102612 <mem_init+0x15cc>
f01025f9:	68 10 3e 10 f0       	push   $0xf0103e10
f01025fe:	68 12 43 10 f0       	push   $0xf0104312
f0102603:	68 8d 03 00 00       	push   $0x38d
f0102608:	68 ec 42 10 f0       	push   $0xf01042ec
f010260d:	e8 aa da ff ff       	call   f01000bc <_panic>
	kern_pgdir[0] = 0;
f0102612:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102618:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010261d:	74 19                	je     f0102638 <mem_init+0x15f2>
f010261f:	68 db 44 10 f0       	push   $0xf01044db
f0102624:	68 12 43 10 f0       	push   $0xf0104312
f0102629:	68 8f 03 00 00       	push   $0x38f
f010262e:	68 ec 42 10 f0       	push   $0xf01042ec
f0102633:	e8 84 da ff ff       	call   f01000bc <_panic>
	pp0->pp_ref = 0;
f0102638:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010263e:	83 ec 0c             	sub    $0xc,%esp
f0102641:	53                   	push   %ebx
f0102642:	e8 9e e7 ff ff       	call   f0100de5 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102647:	c7 04 24 c0 42 10 f0 	movl   $0xf01042c0,(%esp)
f010264e:	e8 7d 00 00 00       	call   f01026d0 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102653:	83 c4 10             	add    $0x10,%esp
f0102656:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102659:	5b                   	pop    %ebx
f010265a:	5e                   	pop    %esi
f010265b:	5f                   	pop    %edi
f010265c:	5d                   	pop    %ebp
f010265d:	c3                   	ret    

f010265e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010265e:	55                   	push   %ebp
f010265f:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102661:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102664:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102667:	5d                   	pop    %ebp
f0102668:	c3                   	ret    

f0102669 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102669:	55                   	push   %ebp
f010266a:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010266c:	ba 70 00 00 00       	mov    $0x70,%edx
f0102671:	8b 45 08             	mov    0x8(%ebp),%eax
f0102674:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102675:	ba 71 00 00 00       	mov    $0x71,%edx
f010267a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010267b:	0f b6 c0             	movzbl %al,%eax
}
f010267e:	5d                   	pop    %ebp
f010267f:	c3                   	ret    

f0102680 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102680:	55                   	push   %ebp
f0102681:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102683:	ba 70 00 00 00       	mov    $0x70,%edx
f0102688:	8b 45 08             	mov    0x8(%ebp),%eax
f010268b:	ee                   	out    %al,(%dx)
f010268c:	ba 71 00 00 00       	mov    $0x71,%edx
f0102691:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102694:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102695:	5d                   	pop    %ebp
f0102696:	c3                   	ret    

f0102697 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102697:	55                   	push   %ebp
f0102698:	89 e5                	mov    %esp,%ebp
f010269a:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010269d:	ff 75 08             	pushl  0x8(%ebp)
f01026a0:	e8 7e df ff ff       	call   f0100623 <cputchar>
	*cnt++;
}
f01026a5:	83 c4 10             	add    $0x10,%esp
f01026a8:	c9                   	leave  
f01026a9:	c3                   	ret    

f01026aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01026aa:	55                   	push   %ebp
f01026ab:	89 e5                	mov    %esp,%ebp
f01026ad:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01026b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01026b7:	ff 75 0c             	pushl  0xc(%ebp)
f01026ba:	ff 75 08             	pushl  0x8(%ebp)
f01026bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01026c0:	50                   	push   %eax
f01026c1:	68 97 26 10 f0       	push   $0xf0102697
f01026c6:	e8 52 04 00 00       	call   f0102b1d <vprintfmt>
	return cnt;
}
f01026cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01026ce:	c9                   	leave  
f01026cf:	c3                   	ret    

f01026d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01026d0:	55                   	push   %ebp
f01026d1:	89 e5                	mov    %esp,%ebp
f01026d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01026d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01026d9:	50                   	push   %eax
f01026da:	ff 75 08             	pushl  0x8(%ebp)
f01026dd:	e8 c8 ff ff ff       	call   f01026aa <vcprintf>
	va_end(ap);

	return cnt;
}
f01026e2:	c9                   	leave  
f01026e3:	c3                   	ret    

f01026e4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01026e4:	55                   	push   %ebp
f01026e5:	89 e5                	mov    %esp,%ebp
f01026e7:	57                   	push   %edi
f01026e8:	56                   	push   %esi
f01026e9:	53                   	push   %ebx
f01026ea:	83 ec 14             	sub    $0x14,%esp
f01026ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01026f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01026f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01026f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01026f9:	8b 1a                	mov    (%edx),%ebx
f01026fb:	8b 01                	mov    (%ecx),%eax
f01026fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102700:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102707:	eb 7f                	jmp    f0102788 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0102709:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010270c:	01 d8                	add    %ebx,%eax
f010270e:	89 c6                	mov    %eax,%esi
f0102710:	c1 ee 1f             	shr    $0x1f,%esi
f0102713:	01 c6                	add    %eax,%esi
f0102715:	d1 fe                	sar    %esi
f0102717:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010271a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010271d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102720:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102722:	eb 03                	jmp    f0102727 <stab_binsearch+0x43>
			m--;
f0102724:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102727:	39 c3                	cmp    %eax,%ebx
f0102729:	7f 0d                	jg     f0102738 <stab_binsearch+0x54>
f010272b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010272f:	83 ea 0c             	sub    $0xc,%edx
f0102732:	39 f9                	cmp    %edi,%ecx
f0102734:	75 ee                	jne    f0102724 <stab_binsearch+0x40>
f0102736:	eb 05                	jmp    f010273d <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102738:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010273b:	eb 4b                	jmp    f0102788 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010273d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102740:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102743:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102747:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010274a:	76 11                	jbe    f010275d <stab_binsearch+0x79>
			*region_left = m;
f010274c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010274f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102751:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102754:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010275b:	eb 2b                	jmp    f0102788 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010275d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102760:	73 14                	jae    f0102776 <stab_binsearch+0x92>
			*region_right = m - 1;
f0102762:	83 e8 01             	sub    $0x1,%eax
f0102765:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102768:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010276b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010276d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102774:	eb 12                	jmp    f0102788 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102776:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102779:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010277b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010277f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102781:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102788:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010278b:	0f 8e 78 ff ff ff    	jle    f0102709 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102791:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102795:	75 0f                	jne    f01027a6 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0102797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010279a:	8b 00                	mov    (%eax),%eax
f010279c:	83 e8 01             	sub    $0x1,%eax
f010279f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01027a2:	89 06                	mov    %eax,(%esi)
f01027a4:	eb 2c                	jmp    f01027d2 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01027a9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01027ab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01027ae:	8b 0e                	mov    (%esi),%ecx
f01027b0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027b3:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01027b6:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027b9:	eb 03                	jmp    f01027be <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01027bb:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027be:	39 c8                	cmp    %ecx,%eax
f01027c0:	7e 0b                	jle    f01027cd <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01027c2:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01027c6:	83 ea 0c             	sub    $0xc,%edx
f01027c9:	39 df                	cmp    %ebx,%edi
f01027cb:	75 ee                	jne    f01027bb <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01027cd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01027d0:	89 06                	mov    %eax,(%esi)
	}
}
f01027d2:	83 c4 14             	add    $0x14,%esp
f01027d5:	5b                   	pop    %ebx
f01027d6:	5e                   	pop    %esi
f01027d7:	5f                   	pop    %edi
f01027d8:	5d                   	pop    %ebp
f01027d9:	c3                   	ret    

f01027da <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01027da:	55                   	push   %ebp
f01027db:	89 e5                	mov    %esp,%ebp
f01027dd:	57                   	push   %edi
f01027de:	56                   	push   %esi
f01027df:	53                   	push   %ebx
f01027e0:	83 ec 3c             	sub    $0x3c,%esp
f01027e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01027e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01027e9:	c7 03 be 45 10 f0    	movl   $0xf01045be,(%ebx)
	info->eip_line = 0;
f01027ef:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01027f6:	c7 43 08 be 45 10 f0 	movl   $0xf01045be,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01027fd:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102804:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102807:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010280e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102814:	76 11                	jbe    f0102827 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102816:	b8 16 bf 10 f0       	mov    $0xf010bf16,%eax
f010281b:	3d b5 a0 10 f0       	cmp    $0xf010a0b5,%eax
f0102820:	77 19                	ja     f010283b <debuginfo_eip+0x61>
f0102822:	e9 aa 01 00 00       	jmp    f01029d1 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102827:	83 ec 04             	sub    $0x4,%esp
f010282a:	68 c8 45 10 f0       	push   $0xf01045c8
f010282f:	6a 7f                	push   $0x7f
f0102831:	68 d5 45 10 f0       	push   $0xf01045d5
f0102836:	e8 81 d8 ff ff       	call   f01000bc <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010283b:	80 3d 15 bf 10 f0 00 	cmpb   $0x0,0xf010bf15
f0102842:	0f 85 90 01 00 00    	jne    f01029d8 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102848:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010284f:	b8 b4 a0 10 f0       	mov    $0xf010a0b4,%eax
f0102854:	2d 10 48 10 f0       	sub    $0xf0104810,%eax
f0102859:	c1 f8 02             	sar    $0x2,%eax
f010285c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102862:	83 e8 01             	sub    $0x1,%eax
f0102865:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102868:	83 ec 08             	sub    $0x8,%esp
f010286b:	56                   	push   %esi
f010286c:	6a 64                	push   $0x64
f010286e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102871:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102874:	b8 10 48 10 f0       	mov    $0xf0104810,%eax
f0102879:	e8 66 fe ff ff       	call   f01026e4 <stab_binsearch>
	if (lfile == 0)
f010287e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102881:	83 c4 10             	add    $0x10,%esp
f0102884:	85 c0                	test   %eax,%eax
f0102886:	0f 84 53 01 00 00    	je     f01029df <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010288c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010288f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102892:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102895:	83 ec 08             	sub    $0x8,%esp
f0102898:	56                   	push   %esi
f0102899:	6a 24                	push   $0x24
f010289b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010289e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01028a1:	b8 10 48 10 f0       	mov    $0xf0104810,%eax
f01028a6:	e8 39 fe ff ff       	call   f01026e4 <stab_binsearch>

	if (lfun <= rfun) {
f01028ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01028ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01028b1:	83 c4 10             	add    $0x10,%esp
f01028b4:	39 d0                	cmp    %edx,%eax
f01028b6:	7f 40                	jg     f01028f8 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01028b8:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01028bb:	c1 e1 02             	shl    $0x2,%ecx
f01028be:	8d b9 10 48 10 f0    	lea    -0xfefb7f0(%ecx),%edi
f01028c4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01028c7:	8b b9 10 48 10 f0    	mov    -0xfefb7f0(%ecx),%edi
f01028cd:	b9 16 bf 10 f0       	mov    $0xf010bf16,%ecx
f01028d2:	81 e9 b5 a0 10 f0    	sub    $0xf010a0b5,%ecx
f01028d8:	39 cf                	cmp    %ecx,%edi
f01028da:	73 09                	jae    f01028e5 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01028dc:	81 c7 b5 a0 10 f0    	add    $0xf010a0b5,%edi
f01028e2:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01028e5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01028e8:	8b 4f 08             	mov    0x8(%edi),%ecx
f01028eb:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01028ee:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01028f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01028f3:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01028f6:	eb 0f                	jmp    f0102907 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01028f8:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01028fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102901:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102904:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102907:	83 ec 08             	sub    $0x8,%esp
f010290a:	6a 3a                	push   $0x3a
f010290c:	ff 73 08             	pushl  0x8(%ebx)
f010290f:	e8 59 08 00 00       	call   f010316d <strfind>
f0102914:	2b 43 08             	sub    0x8(%ebx),%eax
f0102917:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010291a:	83 c4 08             	add    $0x8,%esp
f010291d:	56                   	push   %esi
f010291e:	6a 44                	push   $0x44
f0102920:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102923:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102926:	b8 10 48 10 f0       	mov    $0xf0104810,%eax
f010292b:	e8 b4 fd ff ff       	call   f01026e4 <stab_binsearch>
	if ( lline <= rline ){
f0102930:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102933:	83 c4 10             	add    $0x10,%esp
f0102936:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0102939:	0f 8f a7 00 00 00    	jg     f01029e6 <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f010293f:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102942:	8d 04 85 10 48 10 f0 	lea    -0xfefb7f0(,%eax,4),%eax
f0102949:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f010294d:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102950:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102953:	eb 06                	jmp    f010295b <debuginfo_eip+0x181>
f0102955:	83 ea 01             	sub    $0x1,%edx
f0102958:	83 e8 0c             	sub    $0xc,%eax
f010295b:	39 d6                	cmp    %edx,%esi
f010295d:	7f 34                	jg     f0102993 <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f010295f:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102963:	80 f9 84             	cmp    $0x84,%cl
f0102966:	74 0b                	je     f0102973 <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102968:	80 f9 64             	cmp    $0x64,%cl
f010296b:	75 e8                	jne    f0102955 <debuginfo_eip+0x17b>
f010296d:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102971:	74 e2                	je     f0102955 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102973:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102976:	8b 14 85 10 48 10 f0 	mov    -0xfefb7f0(,%eax,4),%edx
f010297d:	b8 16 bf 10 f0       	mov    $0xf010bf16,%eax
f0102982:	2d b5 a0 10 f0       	sub    $0xf010a0b5,%eax
f0102987:	39 c2                	cmp    %eax,%edx
f0102989:	73 08                	jae    f0102993 <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010298b:	81 c2 b5 a0 10 f0    	add    $0xf010a0b5,%edx
f0102991:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102993:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102996:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102999:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010299e:	39 f2                	cmp    %esi,%edx
f01029a0:	7d 50                	jge    f01029f2 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f01029a2:	83 c2 01             	add    $0x1,%edx
f01029a5:	89 d0                	mov    %edx,%eax
f01029a7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01029aa:	8d 14 95 10 48 10 f0 	lea    -0xfefb7f0(,%edx,4),%edx
f01029b1:	eb 04                	jmp    f01029b7 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01029b3:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01029b7:	39 c6                	cmp    %eax,%esi
f01029b9:	7e 32                	jle    f01029ed <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01029bb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01029bf:	83 c0 01             	add    $0x1,%eax
f01029c2:	83 c2 0c             	add    $0xc,%edx
f01029c5:	80 f9 a0             	cmp    $0xa0,%cl
f01029c8:	74 e9                	je     f01029b3 <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01029cf:	eb 21                	jmp    f01029f2 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01029d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029d6:	eb 1a                	jmp    f01029f2 <debuginfo_eip+0x218>
f01029d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029dd:	eb 13                	jmp    f01029f2 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01029df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029e4:	eb 0c                	jmp    f01029f2 <debuginfo_eip+0x218>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if ( lline <= rline ){
		info->eip_line = stabs[lline].n_desc;
	}
	else{
		return -1;
f01029e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029eb:	eb 05                	jmp    f01029f2 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029f5:	5b                   	pop    %ebx
f01029f6:	5e                   	pop    %esi
f01029f7:	5f                   	pop    %edi
f01029f8:	5d                   	pop    %ebp
f01029f9:	c3                   	ret    

f01029fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01029fa:	55                   	push   %ebp
f01029fb:	89 e5                	mov    %esp,%ebp
f01029fd:	57                   	push   %edi
f01029fe:	56                   	push   %esi
f01029ff:	53                   	push   %ebx
f0102a00:	83 ec 1c             	sub    $0x1c,%esp
f0102a03:	89 c7                	mov    %eax,%edi
f0102a05:	89 d6                	mov    %edx,%esi
f0102a07:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102a0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102a10:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102a16:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a1b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102a1e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102a21:	39 d3                	cmp    %edx,%ebx
f0102a23:	72 05                	jb     f0102a2a <printnum+0x30>
f0102a25:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102a28:	77 45                	ja     f0102a6f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102a2a:	83 ec 0c             	sub    $0xc,%esp
f0102a2d:	ff 75 18             	pushl  0x18(%ebp)
f0102a30:	8b 45 14             	mov    0x14(%ebp),%eax
f0102a33:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102a36:	53                   	push   %ebx
f0102a37:	ff 75 10             	pushl  0x10(%ebp)
f0102a3a:	83 ec 08             	sub    $0x8,%esp
f0102a3d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a40:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a43:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a46:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a49:	e8 42 09 00 00       	call   f0103390 <__udivdi3>
f0102a4e:	83 c4 18             	add    $0x18,%esp
f0102a51:	52                   	push   %edx
f0102a52:	50                   	push   %eax
f0102a53:	89 f2                	mov    %esi,%edx
f0102a55:	89 f8                	mov    %edi,%eax
f0102a57:	e8 9e ff ff ff       	call   f01029fa <printnum>
f0102a5c:	83 c4 20             	add    $0x20,%esp
f0102a5f:	eb 18                	jmp    f0102a79 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102a61:	83 ec 08             	sub    $0x8,%esp
f0102a64:	56                   	push   %esi
f0102a65:	ff 75 18             	pushl  0x18(%ebp)
f0102a68:	ff d7                	call   *%edi
f0102a6a:	83 c4 10             	add    $0x10,%esp
f0102a6d:	eb 03                	jmp    f0102a72 <printnum+0x78>
f0102a6f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102a72:	83 eb 01             	sub    $0x1,%ebx
f0102a75:	85 db                	test   %ebx,%ebx
f0102a77:	7f e8                	jg     f0102a61 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102a79:	83 ec 08             	sub    $0x8,%esp
f0102a7c:	56                   	push   %esi
f0102a7d:	83 ec 04             	sub    $0x4,%esp
f0102a80:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a83:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a86:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a89:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a8c:	e8 2f 0a 00 00       	call   f01034c0 <__umoddi3>
f0102a91:	83 c4 14             	add    $0x14,%esp
f0102a94:	0f be 80 e3 45 10 f0 	movsbl -0xfefba1d(%eax),%eax
f0102a9b:	50                   	push   %eax
f0102a9c:	ff d7                	call   *%edi
}
f0102a9e:	83 c4 10             	add    $0x10,%esp
f0102aa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102aa4:	5b                   	pop    %ebx
f0102aa5:	5e                   	pop    %esi
f0102aa6:	5f                   	pop    %edi
f0102aa7:	5d                   	pop    %ebp
f0102aa8:	c3                   	ret    

f0102aa9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102aa9:	55                   	push   %ebp
f0102aaa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102aac:	83 fa 01             	cmp    $0x1,%edx
f0102aaf:	7e 0e                	jle    f0102abf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102ab1:	8b 10                	mov    (%eax),%edx
f0102ab3:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102ab6:	89 08                	mov    %ecx,(%eax)
f0102ab8:	8b 02                	mov    (%edx),%eax
f0102aba:	8b 52 04             	mov    0x4(%edx),%edx
f0102abd:	eb 22                	jmp    f0102ae1 <getuint+0x38>
	else if (lflag)
f0102abf:	85 d2                	test   %edx,%edx
f0102ac1:	74 10                	je     f0102ad3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102ac3:	8b 10                	mov    (%eax),%edx
f0102ac5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ac8:	89 08                	mov    %ecx,(%eax)
f0102aca:	8b 02                	mov    (%edx),%eax
f0102acc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ad1:	eb 0e                	jmp    f0102ae1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102ad3:	8b 10                	mov    (%eax),%edx
f0102ad5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ad8:	89 08                	mov    %ecx,(%eax)
f0102ada:	8b 02                	mov    (%edx),%eax
f0102adc:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102ae1:	5d                   	pop    %ebp
f0102ae2:	c3                   	ret    

f0102ae3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102ae3:	55                   	push   %ebp
f0102ae4:	89 e5                	mov    %esp,%ebp
f0102ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102ae9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102aed:	8b 10                	mov    (%eax),%edx
f0102aef:	3b 50 04             	cmp    0x4(%eax),%edx
f0102af2:	73 0a                	jae    f0102afe <sprintputch+0x1b>
		*b->buf++ = ch;
f0102af4:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102af7:	89 08                	mov    %ecx,(%eax)
f0102af9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102afc:	88 02                	mov    %al,(%edx)
}
f0102afe:	5d                   	pop    %ebp
f0102aff:	c3                   	ret    

f0102b00 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102b00:	55                   	push   %ebp
f0102b01:	89 e5                	mov    %esp,%ebp
f0102b03:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b06:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b09:	50                   	push   %eax
f0102b0a:	ff 75 10             	pushl  0x10(%ebp)
f0102b0d:	ff 75 0c             	pushl  0xc(%ebp)
f0102b10:	ff 75 08             	pushl  0x8(%ebp)
f0102b13:	e8 05 00 00 00       	call   f0102b1d <vprintfmt>
	va_end(ap);
}
f0102b18:	83 c4 10             	add    $0x10,%esp
f0102b1b:	c9                   	leave  
f0102b1c:	c3                   	ret    

f0102b1d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102b1d:	55                   	push   %ebp
f0102b1e:	89 e5                	mov    %esp,%ebp
f0102b20:	57                   	push   %edi
f0102b21:	56                   	push   %esi
f0102b22:	53                   	push   %ebx
f0102b23:	83 ec 2c             	sub    $0x2c,%esp
f0102b26:	8b 75 08             	mov    0x8(%ebp),%esi
f0102b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102b2c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102b2f:	eb 12                	jmp    f0102b43 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102b31:	85 c0                	test   %eax,%eax
f0102b33:	0f 84 89 03 00 00    	je     f0102ec2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102b39:	83 ec 08             	sub    $0x8,%esp
f0102b3c:	53                   	push   %ebx
f0102b3d:	50                   	push   %eax
f0102b3e:	ff d6                	call   *%esi
f0102b40:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102b43:	83 c7 01             	add    $0x1,%edi
f0102b46:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102b4a:	83 f8 25             	cmp    $0x25,%eax
f0102b4d:	75 e2                	jne    f0102b31 <vprintfmt+0x14>
f0102b4f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102b53:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102b5a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102b61:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102b68:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b6d:	eb 07                	jmp    f0102b76 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102b72:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b76:	8d 47 01             	lea    0x1(%edi),%eax
f0102b79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102b7c:	0f b6 07             	movzbl (%edi),%eax
f0102b7f:	0f b6 c8             	movzbl %al,%ecx
f0102b82:	83 e8 23             	sub    $0x23,%eax
f0102b85:	3c 55                	cmp    $0x55,%al
f0102b87:	0f 87 1a 03 00 00    	ja     f0102ea7 <vprintfmt+0x38a>
f0102b8d:	0f b6 c0             	movzbl %al,%eax
f0102b90:	ff 24 85 80 46 10 f0 	jmp    *-0xfefb980(,%eax,4)
f0102b97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102b9a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102b9e:	eb d6                	jmp    f0102b76 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ba0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ba3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ba8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102bab:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102bae:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102bb2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102bb5:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102bb8:	83 fa 09             	cmp    $0x9,%edx
f0102bbb:	77 39                	ja     f0102bf6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102bbd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102bc0:	eb e9                	jmp    f0102bab <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102bc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bc5:	8d 48 04             	lea    0x4(%eax),%ecx
f0102bc8:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102bcb:	8b 00                	mov    (%eax),%eax
f0102bcd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102bd3:	eb 27                	jmp    f0102bfc <vprintfmt+0xdf>
f0102bd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102bd8:	85 c0                	test   %eax,%eax
f0102bda:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102bdf:	0f 49 c8             	cmovns %eax,%ecx
f0102be2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102be5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102be8:	eb 8c                	jmp    f0102b76 <vprintfmt+0x59>
f0102bea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102bed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102bf4:	eb 80                	jmp    f0102b76 <vprintfmt+0x59>
f0102bf6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102bf9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102bfc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c00:	0f 89 70 ff ff ff    	jns    f0102b76 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102c06:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c09:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102c0c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c13:	e9 5e ff ff ff       	jmp    f0102b76 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102c18:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c1b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102c1e:	e9 53 ff ff ff       	jmp    f0102b76 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102c23:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c26:	8d 50 04             	lea    0x4(%eax),%edx
f0102c29:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c2c:	83 ec 08             	sub    $0x8,%esp
f0102c2f:	53                   	push   %ebx
f0102c30:	ff 30                	pushl  (%eax)
f0102c32:	ff d6                	call   *%esi
			break;
f0102c34:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102c3a:	e9 04 ff ff ff       	jmp    f0102b43 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102c3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c42:	8d 50 04             	lea    0x4(%eax),%edx
f0102c45:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c48:	8b 00                	mov    (%eax),%eax
f0102c4a:	99                   	cltd   
f0102c4b:	31 d0                	xor    %edx,%eax
f0102c4d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102c4f:	83 f8 07             	cmp    $0x7,%eax
f0102c52:	7f 0b                	jg     f0102c5f <vprintfmt+0x142>
f0102c54:	8b 14 85 e0 47 10 f0 	mov    -0xfefb820(,%eax,4),%edx
f0102c5b:	85 d2                	test   %edx,%edx
f0102c5d:	75 18                	jne    f0102c77 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102c5f:	50                   	push   %eax
f0102c60:	68 fb 45 10 f0       	push   $0xf01045fb
f0102c65:	53                   	push   %ebx
f0102c66:	56                   	push   %esi
f0102c67:	e8 94 fe ff ff       	call   f0102b00 <printfmt>
f0102c6c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102c72:	e9 cc fe ff ff       	jmp    f0102b43 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102c77:	52                   	push   %edx
f0102c78:	68 24 43 10 f0       	push   $0xf0104324
f0102c7d:	53                   	push   %ebx
f0102c7e:	56                   	push   %esi
f0102c7f:	e8 7c fe ff ff       	call   f0102b00 <printfmt>
f0102c84:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c8a:	e9 b4 fe ff ff       	jmp    f0102b43 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102c8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c92:	8d 50 04             	lea    0x4(%eax),%edx
f0102c95:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c98:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102c9a:	85 ff                	test   %edi,%edi
f0102c9c:	b8 f4 45 10 f0       	mov    $0xf01045f4,%eax
f0102ca1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102ca4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102ca8:	0f 8e 94 00 00 00    	jle    f0102d42 <vprintfmt+0x225>
f0102cae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102cb2:	0f 84 98 00 00 00    	je     f0102d50 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cb8:	83 ec 08             	sub    $0x8,%esp
f0102cbb:	ff 75 d0             	pushl  -0x30(%ebp)
f0102cbe:	57                   	push   %edi
f0102cbf:	e8 5f 03 00 00       	call   f0103023 <strnlen>
f0102cc4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102cc7:	29 c1                	sub    %eax,%ecx
f0102cc9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102ccc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102ccf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102cd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102cd6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102cd9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cdb:	eb 0f                	jmp    f0102cec <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102cdd:	83 ec 08             	sub    $0x8,%esp
f0102ce0:	53                   	push   %ebx
f0102ce1:	ff 75 e0             	pushl  -0x20(%ebp)
f0102ce4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102ce6:	83 ef 01             	sub    $0x1,%edi
f0102ce9:	83 c4 10             	add    $0x10,%esp
f0102cec:	85 ff                	test   %edi,%edi
f0102cee:	7f ed                	jg     f0102cdd <vprintfmt+0x1c0>
f0102cf0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102cf3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102cf6:	85 c9                	test   %ecx,%ecx
f0102cf8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cfd:	0f 49 c1             	cmovns %ecx,%eax
f0102d00:	29 c1                	sub    %eax,%ecx
f0102d02:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d05:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d08:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d0b:	89 cb                	mov    %ecx,%ebx
f0102d0d:	eb 4d                	jmp    f0102d5c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102d0f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102d13:	74 1b                	je     f0102d30 <vprintfmt+0x213>
f0102d15:	0f be c0             	movsbl %al,%eax
f0102d18:	83 e8 20             	sub    $0x20,%eax
f0102d1b:	83 f8 5e             	cmp    $0x5e,%eax
f0102d1e:	76 10                	jbe    f0102d30 <vprintfmt+0x213>
					putch('?', putdat);
f0102d20:	83 ec 08             	sub    $0x8,%esp
f0102d23:	ff 75 0c             	pushl  0xc(%ebp)
f0102d26:	6a 3f                	push   $0x3f
f0102d28:	ff 55 08             	call   *0x8(%ebp)
f0102d2b:	83 c4 10             	add    $0x10,%esp
f0102d2e:	eb 0d                	jmp    f0102d3d <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102d30:	83 ec 08             	sub    $0x8,%esp
f0102d33:	ff 75 0c             	pushl  0xc(%ebp)
f0102d36:	52                   	push   %edx
f0102d37:	ff 55 08             	call   *0x8(%ebp)
f0102d3a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d3d:	83 eb 01             	sub    $0x1,%ebx
f0102d40:	eb 1a                	jmp    f0102d5c <vprintfmt+0x23f>
f0102d42:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d45:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d48:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d4b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d4e:	eb 0c                	jmp    f0102d5c <vprintfmt+0x23f>
f0102d50:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d53:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d56:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d59:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d5c:	83 c7 01             	add    $0x1,%edi
f0102d5f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102d63:	0f be d0             	movsbl %al,%edx
f0102d66:	85 d2                	test   %edx,%edx
f0102d68:	74 23                	je     f0102d8d <vprintfmt+0x270>
f0102d6a:	85 f6                	test   %esi,%esi
f0102d6c:	78 a1                	js     f0102d0f <vprintfmt+0x1f2>
f0102d6e:	83 ee 01             	sub    $0x1,%esi
f0102d71:	79 9c                	jns    f0102d0f <vprintfmt+0x1f2>
f0102d73:	89 df                	mov    %ebx,%edi
f0102d75:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d7b:	eb 18                	jmp    f0102d95 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102d7d:	83 ec 08             	sub    $0x8,%esp
f0102d80:	53                   	push   %ebx
f0102d81:	6a 20                	push   $0x20
f0102d83:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102d85:	83 ef 01             	sub    $0x1,%edi
f0102d88:	83 c4 10             	add    $0x10,%esp
f0102d8b:	eb 08                	jmp    f0102d95 <vprintfmt+0x278>
f0102d8d:	89 df                	mov    %ebx,%edi
f0102d8f:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d95:	85 ff                	test   %edi,%edi
f0102d97:	7f e4                	jg     f0102d7d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d9c:	e9 a2 fd ff ff       	jmp    f0102b43 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102da1:	83 fa 01             	cmp    $0x1,%edx
f0102da4:	7e 16                	jle    f0102dbc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102da6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102da9:	8d 50 08             	lea    0x8(%eax),%edx
f0102dac:	89 55 14             	mov    %edx,0x14(%ebp)
f0102daf:	8b 50 04             	mov    0x4(%eax),%edx
f0102db2:	8b 00                	mov    (%eax),%eax
f0102db4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102db7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102dba:	eb 32                	jmp    f0102dee <vprintfmt+0x2d1>
	else if (lflag)
f0102dbc:	85 d2                	test   %edx,%edx
f0102dbe:	74 18                	je     f0102dd8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102dc0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dc3:	8d 50 04             	lea    0x4(%eax),%edx
f0102dc6:	89 55 14             	mov    %edx,0x14(%ebp)
f0102dc9:	8b 00                	mov    (%eax),%eax
f0102dcb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dce:	89 c1                	mov    %eax,%ecx
f0102dd0:	c1 f9 1f             	sar    $0x1f,%ecx
f0102dd3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102dd6:	eb 16                	jmp    f0102dee <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102dd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ddb:	8d 50 04             	lea    0x4(%eax),%edx
f0102dde:	89 55 14             	mov    %edx,0x14(%ebp)
f0102de1:	8b 00                	mov    (%eax),%eax
f0102de3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102de6:	89 c1                	mov    %eax,%ecx
f0102de8:	c1 f9 1f             	sar    $0x1f,%ecx
f0102deb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102dee:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102df1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102df4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102df9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102dfd:	79 74                	jns    f0102e73 <vprintfmt+0x356>
				putch('-', putdat);
f0102dff:	83 ec 08             	sub    $0x8,%esp
f0102e02:	53                   	push   %ebx
f0102e03:	6a 2d                	push   $0x2d
f0102e05:	ff d6                	call   *%esi
				num = -(long long) num;
f0102e07:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e0a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e0d:	f7 d8                	neg    %eax
f0102e0f:	83 d2 00             	adc    $0x0,%edx
f0102e12:	f7 da                	neg    %edx
f0102e14:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102e17:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102e1c:	eb 55                	jmp    f0102e73 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102e1e:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e21:	e8 83 fc ff ff       	call   f0102aa9 <getuint>
			base = 10;
f0102e26:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102e2b:	eb 46                	jmp    f0102e73 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0102e2d:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e30:	e8 74 fc ff ff       	call   f0102aa9 <getuint>
			base = 8;
f0102e35:	b9 08 00 00 00       	mov    $0x8,%ecx
			//putch('\\',putdat);
			goto number;
f0102e3a:	eb 37                	jmp    f0102e73 <vprintfmt+0x356>
			//putch('X', putdat);
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0102e3c:	83 ec 08             	sub    $0x8,%esp
f0102e3f:	53                   	push   %ebx
f0102e40:	6a 30                	push   $0x30
f0102e42:	ff d6                	call   *%esi
			putch('x', putdat);
f0102e44:	83 c4 08             	add    $0x8,%esp
f0102e47:	53                   	push   %ebx
f0102e48:	6a 78                	push   $0x78
f0102e4a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102e4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e4f:	8d 50 04             	lea    0x4(%eax),%edx
f0102e52:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102e55:	8b 00                	mov    (%eax),%eax
f0102e57:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102e5c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102e5f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102e64:	eb 0d                	jmp    f0102e73 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102e66:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e69:	e8 3b fc ff ff       	call   f0102aa9 <getuint>
			base = 16;
f0102e6e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102e73:	83 ec 0c             	sub    $0xc,%esp
f0102e76:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102e7a:	57                   	push   %edi
f0102e7b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e7e:	51                   	push   %ecx
f0102e7f:	52                   	push   %edx
f0102e80:	50                   	push   %eax
f0102e81:	89 da                	mov    %ebx,%edx
f0102e83:	89 f0                	mov    %esi,%eax
f0102e85:	e8 70 fb ff ff       	call   f01029fa <printnum>
			break;
f0102e8a:	83 c4 20             	add    $0x20,%esp
f0102e8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e90:	e9 ae fc ff ff       	jmp    f0102b43 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102e95:	83 ec 08             	sub    $0x8,%esp
f0102e98:	53                   	push   %ebx
f0102e99:	51                   	push   %ecx
f0102e9a:	ff d6                	call   *%esi
			break;
f0102e9c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102ea2:	e9 9c fc ff ff       	jmp    f0102b43 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102ea7:	83 ec 08             	sub    $0x8,%esp
f0102eaa:	53                   	push   %ebx
f0102eab:	6a 25                	push   $0x25
f0102ead:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102eaf:	83 c4 10             	add    $0x10,%esp
f0102eb2:	eb 03                	jmp    f0102eb7 <vprintfmt+0x39a>
f0102eb4:	83 ef 01             	sub    $0x1,%edi
f0102eb7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102ebb:	75 f7                	jne    f0102eb4 <vprintfmt+0x397>
f0102ebd:	e9 81 fc ff ff       	jmp    f0102b43 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ec5:	5b                   	pop    %ebx
f0102ec6:	5e                   	pop    %esi
f0102ec7:	5f                   	pop    %edi
f0102ec8:	5d                   	pop    %ebp
f0102ec9:	c3                   	ret    

f0102eca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102eca:	55                   	push   %ebp
f0102ecb:	89 e5                	mov    %esp,%ebp
f0102ecd:	83 ec 18             	sub    $0x18,%esp
f0102ed0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102ed6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102ed9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102edd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102ee0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102ee7:	85 c0                	test   %eax,%eax
f0102ee9:	74 26                	je     f0102f11 <vsnprintf+0x47>
f0102eeb:	85 d2                	test   %edx,%edx
f0102eed:	7e 22                	jle    f0102f11 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102eef:	ff 75 14             	pushl  0x14(%ebp)
f0102ef2:	ff 75 10             	pushl  0x10(%ebp)
f0102ef5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102ef8:	50                   	push   %eax
f0102ef9:	68 e3 2a 10 f0       	push   $0xf0102ae3
f0102efe:	e8 1a fc ff ff       	call   f0102b1d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f06:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f0c:	83 c4 10             	add    $0x10,%esp
f0102f0f:	eb 05                	jmp    f0102f16 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102f16:	c9                   	leave  
f0102f17:	c3                   	ret    

f0102f18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102f18:	55                   	push   %ebp
f0102f19:	89 e5                	mov    %esp,%ebp
f0102f1b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102f1e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102f21:	50                   	push   %eax
f0102f22:	ff 75 10             	pushl  0x10(%ebp)
f0102f25:	ff 75 0c             	pushl  0xc(%ebp)
f0102f28:	ff 75 08             	pushl  0x8(%ebp)
f0102f2b:	e8 9a ff ff ff       	call   f0102eca <vsnprintf>
	va_end(ap);

	return rc;
}
f0102f30:	c9                   	leave  
f0102f31:	c3                   	ret    

f0102f32 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102f32:	55                   	push   %ebp
f0102f33:	89 e5                	mov    %esp,%ebp
f0102f35:	57                   	push   %edi
f0102f36:	56                   	push   %esi
f0102f37:	53                   	push   %ebx
f0102f38:	83 ec 0c             	sub    $0xc,%esp
f0102f3b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102f3e:	85 c0                	test   %eax,%eax
f0102f40:	74 11                	je     f0102f53 <readline+0x21>
		cprintf("%s", prompt);
f0102f42:	83 ec 08             	sub    $0x8,%esp
f0102f45:	50                   	push   %eax
f0102f46:	68 24 43 10 f0       	push   $0xf0104324
f0102f4b:	e8 80 f7 ff ff       	call   f01026d0 <cprintf>
f0102f50:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102f53:	83 ec 0c             	sub    $0xc,%esp
f0102f56:	6a 00                	push   $0x0
f0102f58:	e8 e7 d6 ff ff       	call   f0100644 <iscons>
f0102f5d:	89 c7                	mov    %eax,%edi
f0102f5f:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102f62:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102f67:	e8 c7 d6 ff ff       	call   f0100633 <getchar>
f0102f6c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102f6e:	85 c0                	test   %eax,%eax
f0102f70:	79 18                	jns    f0102f8a <readline+0x58>
			cprintf("read error: %e\n", c);
f0102f72:	83 ec 08             	sub    $0x8,%esp
f0102f75:	50                   	push   %eax
f0102f76:	68 00 48 10 f0       	push   $0xf0104800
f0102f7b:	e8 50 f7 ff ff       	call   f01026d0 <cprintf>
			return NULL;
f0102f80:	83 c4 10             	add    $0x10,%esp
f0102f83:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f88:	eb 79                	jmp    f0103003 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102f8a:	83 f8 08             	cmp    $0x8,%eax
f0102f8d:	0f 94 c2             	sete   %dl
f0102f90:	83 f8 7f             	cmp    $0x7f,%eax
f0102f93:	0f 94 c0             	sete   %al
f0102f96:	08 c2                	or     %al,%dl
f0102f98:	74 1a                	je     f0102fb4 <readline+0x82>
f0102f9a:	85 f6                	test   %esi,%esi
f0102f9c:	7e 16                	jle    f0102fb4 <readline+0x82>
			if (echoing)
f0102f9e:	85 ff                	test   %edi,%edi
f0102fa0:	74 0d                	je     f0102faf <readline+0x7d>
				cputchar('\b');
f0102fa2:	83 ec 0c             	sub    $0xc,%esp
f0102fa5:	6a 08                	push   $0x8
f0102fa7:	e8 77 d6 ff ff       	call   f0100623 <cputchar>
f0102fac:	83 c4 10             	add    $0x10,%esp
			i--;
f0102faf:	83 ee 01             	sub    $0x1,%esi
f0102fb2:	eb b3                	jmp    f0102f67 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102fb4:	83 fb 1f             	cmp    $0x1f,%ebx
f0102fb7:	7e 23                	jle    f0102fdc <readline+0xaa>
f0102fb9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102fbf:	7f 1b                	jg     f0102fdc <readline+0xaa>
			if (echoing)
f0102fc1:	85 ff                	test   %edi,%edi
f0102fc3:	74 0c                	je     f0102fd1 <readline+0x9f>
				cputchar(c);
f0102fc5:	83 ec 0c             	sub    $0xc,%esp
f0102fc8:	53                   	push   %ebx
f0102fc9:	e8 55 d6 ff ff       	call   f0100623 <cputchar>
f0102fce:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102fd1:	88 9e 60 65 11 f0    	mov    %bl,-0xfee9aa0(%esi)
f0102fd7:	8d 76 01             	lea    0x1(%esi),%esi
f0102fda:	eb 8b                	jmp    f0102f67 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102fdc:	83 fb 0a             	cmp    $0xa,%ebx
f0102fdf:	74 05                	je     f0102fe6 <readline+0xb4>
f0102fe1:	83 fb 0d             	cmp    $0xd,%ebx
f0102fe4:	75 81                	jne    f0102f67 <readline+0x35>
			if (echoing)
f0102fe6:	85 ff                	test   %edi,%edi
f0102fe8:	74 0d                	je     f0102ff7 <readline+0xc5>
				cputchar('\n');
f0102fea:	83 ec 0c             	sub    $0xc,%esp
f0102fed:	6a 0a                	push   $0xa
f0102fef:	e8 2f d6 ff ff       	call   f0100623 <cputchar>
f0102ff4:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0102ff7:	c6 86 60 65 11 f0 00 	movb   $0x0,-0xfee9aa0(%esi)
			return buf;
f0102ffe:	b8 60 65 11 f0       	mov    $0xf0116560,%eax
		}
	}
}
f0103003:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103006:	5b                   	pop    %ebx
f0103007:	5e                   	pop    %esi
f0103008:	5f                   	pop    %edi
f0103009:	5d                   	pop    %ebp
f010300a:	c3                   	ret    

f010300b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010300b:	55                   	push   %ebp
f010300c:	89 e5                	mov    %esp,%ebp
f010300e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103011:	b8 00 00 00 00       	mov    $0x0,%eax
f0103016:	eb 03                	jmp    f010301b <strlen+0x10>
		n++;
f0103018:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010301b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010301f:	75 f7                	jne    f0103018 <strlen+0xd>
		n++;
	return n;
}
f0103021:	5d                   	pop    %ebp
f0103022:	c3                   	ret    

f0103023 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103023:	55                   	push   %ebp
f0103024:	89 e5                	mov    %esp,%ebp
f0103026:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103029:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010302c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103031:	eb 03                	jmp    f0103036 <strnlen+0x13>
		n++;
f0103033:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103036:	39 c2                	cmp    %eax,%edx
f0103038:	74 08                	je     f0103042 <strnlen+0x1f>
f010303a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010303e:	75 f3                	jne    f0103033 <strnlen+0x10>
f0103040:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103042:	5d                   	pop    %ebp
f0103043:	c3                   	ret    

f0103044 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103044:	55                   	push   %ebp
f0103045:	89 e5                	mov    %esp,%ebp
f0103047:	53                   	push   %ebx
f0103048:	8b 45 08             	mov    0x8(%ebp),%eax
f010304b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010304e:	89 c2                	mov    %eax,%edx
f0103050:	83 c2 01             	add    $0x1,%edx
f0103053:	83 c1 01             	add    $0x1,%ecx
f0103056:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010305a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010305d:	84 db                	test   %bl,%bl
f010305f:	75 ef                	jne    f0103050 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103061:	5b                   	pop    %ebx
f0103062:	5d                   	pop    %ebp
f0103063:	c3                   	ret    

f0103064 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103064:	55                   	push   %ebp
f0103065:	89 e5                	mov    %esp,%ebp
f0103067:	53                   	push   %ebx
f0103068:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010306b:	53                   	push   %ebx
f010306c:	e8 9a ff ff ff       	call   f010300b <strlen>
f0103071:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103074:	ff 75 0c             	pushl  0xc(%ebp)
f0103077:	01 d8                	add    %ebx,%eax
f0103079:	50                   	push   %eax
f010307a:	e8 c5 ff ff ff       	call   f0103044 <strcpy>
	return dst;
}
f010307f:	89 d8                	mov    %ebx,%eax
f0103081:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103084:	c9                   	leave  
f0103085:	c3                   	ret    

f0103086 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103086:	55                   	push   %ebp
f0103087:	89 e5                	mov    %esp,%ebp
f0103089:	56                   	push   %esi
f010308a:	53                   	push   %ebx
f010308b:	8b 75 08             	mov    0x8(%ebp),%esi
f010308e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103091:	89 f3                	mov    %esi,%ebx
f0103093:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103096:	89 f2                	mov    %esi,%edx
f0103098:	eb 0f                	jmp    f01030a9 <strncpy+0x23>
		*dst++ = *src;
f010309a:	83 c2 01             	add    $0x1,%edx
f010309d:	0f b6 01             	movzbl (%ecx),%eax
f01030a0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01030a3:	80 39 01             	cmpb   $0x1,(%ecx)
f01030a6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01030a9:	39 da                	cmp    %ebx,%edx
f01030ab:	75 ed                	jne    f010309a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01030ad:	89 f0                	mov    %esi,%eax
f01030af:	5b                   	pop    %ebx
f01030b0:	5e                   	pop    %esi
f01030b1:	5d                   	pop    %ebp
f01030b2:	c3                   	ret    

f01030b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01030b3:	55                   	push   %ebp
f01030b4:	89 e5                	mov    %esp,%ebp
f01030b6:	56                   	push   %esi
f01030b7:	53                   	push   %ebx
f01030b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01030bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030be:	8b 55 10             	mov    0x10(%ebp),%edx
f01030c1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01030c3:	85 d2                	test   %edx,%edx
f01030c5:	74 21                	je     f01030e8 <strlcpy+0x35>
f01030c7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01030cb:	89 f2                	mov    %esi,%edx
f01030cd:	eb 09                	jmp    f01030d8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01030cf:	83 c2 01             	add    $0x1,%edx
f01030d2:	83 c1 01             	add    $0x1,%ecx
f01030d5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01030d8:	39 c2                	cmp    %eax,%edx
f01030da:	74 09                	je     f01030e5 <strlcpy+0x32>
f01030dc:	0f b6 19             	movzbl (%ecx),%ebx
f01030df:	84 db                	test   %bl,%bl
f01030e1:	75 ec                	jne    f01030cf <strlcpy+0x1c>
f01030e3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01030e5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01030e8:	29 f0                	sub    %esi,%eax
}
f01030ea:	5b                   	pop    %ebx
f01030eb:	5e                   	pop    %esi
f01030ec:	5d                   	pop    %ebp
f01030ed:	c3                   	ret    

f01030ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01030ee:	55                   	push   %ebp
f01030ef:	89 e5                	mov    %esp,%ebp
f01030f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01030f7:	eb 06                	jmp    f01030ff <strcmp+0x11>
		p++, q++;
f01030f9:	83 c1 01             	add    $0x1,%ecx
f01030fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01030ff:	0f b6 01             	movzbl (%ecx),%eax
f0103102:	84 c0                	test   %al,%al
f0103104:	74 04                	je     f010310a <strcmp+0x1c>
f0103106:	3a 02                	cmp    (%edx),%al
f0103108:	74 ef                	je     f01030f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010310a:	0f b6 c0             	movzbl %al,%eax
f010310d:	0f b6 12             	movzbl (%edx),%edx
f0103110:	29 d0                	sub    %edx,%eax
}
f0103112:	5d                   	pop    %ebp
f0103113:	c3                   	ret    

f0103114 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103114:	55                   	push   %ebp
f0103115:	89 e5                	mov    %esp,%ebp
f0103117:	53                   	push   %ebx
f0103118:	8b 45 08             	mov    0x8(%ebp),%eax
f010311b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010311e:	89 c3                	mov    %eax,%ebx
f0103120:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103123:	eb 06                	jmp    f010312b <strncmp+0x17>
		n--, p++, q++;
f0103125:	83 c0 01             	add    $0x1,%eax
f0103128:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010312b:	39 d8                	cmp    %ebx,%eax
f010312d:	74 15                	je     f0103144 <strncmp+0x30>
f010312f:	0f b6 08             	movzbl (%eax),%ecx
f0103132:	84 c9                	test   %cl,%cl
f0103134:	74 04                	je     f010313a <strncmp+0x26>
f0103136:	3a 0a                	cmp    (%edx),%cl
f0103138:	74 eb                	je     f0103125 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010313a:	0f b6 00             	movzbl (%eax),%eax
f010313d:	0f b6 12             	movzbl (%edx),%edx
f0103140:	29 d0                	sub    %edx,%eax
f0103142:	eb 05                	jmp    f0103149 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103144:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103149:	5b                   	pop    %ebx
f010314a:	5d                   	pop    %ebp
f010314b:	c3                   	ret    

f010314c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010314c:	55                   	push   %ebp
f010314d:	89 e5                	mov    %esp,%ebp
f010314f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103152:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103156:	eb 07                	jmp    f010315f <strchr+0x13>
		if (*s == c)
f0103158:	38 ca                	cmp    %cl,%dl
f010315a:	74 0f                	je     f010316b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010315c:	83 c0 01             	add    $0x1,%eax
f010315f:	0f b6 10             	movzbl (%eax),%edx
f0103162:	84 d2                	test   %dl,%dl
f0103164:	75 f2                	jne    f0103158 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103166:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010316b:	5d                   	pop    %ebp
f010316c:	c3                   	ret    

f010316d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010316d:	55                   	push   %ebp
f010316e:	89 e5                	mov    %esp,%ebp
f0103170:	8b 45 08             	mov    0x8(%ebp),%eax
f0103173:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103177:	eb 03                	jmp    f010317c <strfind+0xf>
f0103179:	83 c0 01             	add    $0x1,%eax
f010317c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010317f:	38 ca                	cmp    %cl,%dl
f0103181:	74 04                	je     f0103187 <strfind+0x1a>
f0103183:	84 d2                	test   %dl,%dl
f0103185:	75 f2                	jne    f0103179 <strfind+0xc>
			break;
	return (char *) s;
}
f0103187:	5d                   	pop    %ebp
f0103188:	c3                   	ret    

f0103189 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103189:	55                   	push   %ebp
f010318a:	89 e5                	mov    %esp,%ebp
f010318c:	57                   	push   %edi
f010318d:	56                   	push   %esi
f010318e:	53                   	push   %ebx
f010318f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103192:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103195:	85 c9                	test   %ecx,%ecx
f0103197:	74 36                	je     f01031cf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103199:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010319f:	75 28                	jne    f01031c9 <memset+0x40>
f01031a1:	f6 c1 03             	test   $0x3,%cl
f01031a4:	75 23                	jne    f01031c9 <memset+0x40>
		c &= 0xFF;
f01031a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01031aa:	89 d3                	mov    %edx,%ebx
f01031ac:	c1 e3 08             	shl    $0x8,%ebx
f01031af:	89 d6                	mov    %edx,%esi
f01031b1:	c1 e6 18             	shl    $0x18,%esi
f01031b4:	89 d0                	mov    %edx,%eax
f01031b6:	c1 e0 10             	shl    $0x10,%eax
f01031b9:	09 f0                	or     %esi,%eax
f01031bb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01031bd:	89 d8                	mov    %ebx,%eax
f01031bf:	09 d0                	or     %edx,%eax
f01031c1:	c1 e9 02             	shr    $0x2,%ecx
f01031c4:	fc                   	cld    
f01031c5:	f3 ab                	rep stos %eax,%es:(%edi)
f01031c7:	eb 06                	jmp    f01031cf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01031c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031cc:	fc                   	cld    
f01031cd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01031cf:	89 f8                	mov    %edi,%eax
f01031d1:	5b                   	pop    %ebx
f01031d2:	5e                   	pop    %esi
f01031d3:	5f                   	pop    %edi
f01031d4:	5d                   	pop    %ebp
f01031d5:	c3                   	ret    

f01031d6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01031d6:	55                   	push   %ebp
f01031d7:	89 e5                	mov    %esp,%ebp
f01031d9:	57                   	push   %edi
f01031da:	56                   	push   %esi
f01031db:	8b 45 08             	mov    0x8(%ebp),%eax
f01031de:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01031e4:	39 c6                	cmp    %eax,%esi
f01031e6:	73 35                	jae    f010321d <memmove+0x47>
f01031e8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01031eb:	39 d0                	cmp    %edx,%eax
f01031ed:	73 2e                	jae    f010321d <memmove+0x47>
		s += n;
		d += n;
f01031ef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031f2:	89 d6                	mov    %edx,%esi
f01031f4:	09 fe                	or     %edi,%esi
f01031f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01031fc:	75 13                	jne    f0103211 <memmove+0x3b>
f01031fe:	f6 c1 03             	test   $0x3,%cl
f0103201:	75 0e                	jne    f0103211 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103203:	83 ef 04             	sub    $0x4,%edi
f0103206:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103209:	c1 e9 02             	shr    $0x2,%ecx
f010320c:	fd                   	std    
f010320d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010320f:	eb 09                	jmp    f010321a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103211:	83 ef 01             	sub    $0x1,%edi
f0103214:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103217:	fd                   	std    
f0103218:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010321a:	fc                   	cld    
f010321b:	eb 1d                	jmp    f010323a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010321d:	89 f2                	mov    %esi,%edx
f010321f:	09 c2                	or     %eax,%edx
f0103221:	f6 c2 03             	test   $0x3,%dl
f0103224:	75 0f                	jne    f0103235 <memmove+0x5f>
f0103226:	f6 c1 03             	test   $0x3,%cl
f0103229:	75 0a                	jne    f0103235 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010322b:	c1 e9 02             	shr    $0x2,%ecx
f010322e:	89 c7                	mov    %eax,%edi
f0103230:	fc                   	cld    
f0103231:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103233:	eb 05                	jmp    f010323a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103235:	89 c7                	mov    %eax,%edi
f0103237:	fc                   	cld    
f0103238:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010323a:	5e                   	pop    %esi
f010323b:	5f                   	pop    %edi
f010323c:	5d                   	pop    %ebp
f010323d:	c3                   	ret    

f010323e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010323e:	55                   	push   %ebp
f010323f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103241:	ff 75 10             	pushl  0x10(%ebp)
f0103244:	ff 75 0c             	pushl  0xc(%ebp)
f0103247:	ff 75 08             	pushl  0x8(%ebp)
f010324a:	e8 87 ff ff ff       	call   f01031d6 <memmove>
}
f010324f:	c9                   	leave  
f0103250:	c3                   	ret    

f0103251 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103251:	55                   	push   %ebp
f0103252:	89 e5                	mov    %esp,%ebp
f0103254:	56                   	push   %esi
f0103255:	53                   	push   %ebx
f0103256:	8b 45 08             	mov    0x8(%ebp),%eax
f0103259:	8b 55 0c             	mov    0xc(%ebp),%edx
f010325c:	89 c6                	mov    %eax,%esi
f010325e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103261:	eb 1a                	jmp    f010327d <memcmp+0x2c>
		if (*s1 != *s2)
f0103263:	0f b6 08             	movzbl (%eax),%ecx
f0103266:	0f b6 1a             	movzbl (%edx),%ebx
f0103269:	38 d9                	cmp    %bl,%cl
f010326b:	74 0a                	je     f0103277 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010326d:	0f b6 c1             	movzbl %cl,%eax
f0103270:	0f b6 db             	movzbl %bl,%ebx
f0103273:	29 d8                	sub    %ebx,%eax
f0103275:	eb 0f                	jmp    f0103286 <memcmp+0x35>
		s1++, s2++;
f0103277:	83 c0 01             	add    $0x1,%eax
f010327a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010327d:	39 f0                	cmp    %esi,%eax
f010327f:	75 e2                	jne    f0103263 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103281:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103286:	5b                   	pop    %ebx
f0103287:	5e                   	pop    %esi
f0103288:	5d                   	pop    %ebp
f0103289:	c3                   	ret    

f010328a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010328a:	55                   	push   %ebp
f010328b:	89 e5                	mov    %esp,%ebp
f010328d:	53                   	push   %ebx
f010328e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103291:	89 c1                	mov    %eax,%ecx
f0103293:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103296:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010329a:	eb 0a                	jmp    f01032a6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010329c:	0f b6 10             	movzbl (%eax),%edx
f010329f:	39 da                	cmp    %ebx,%edx
f01032a1:	74 07                	je     f01032aa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01032a3:	83 c0 01             	add    $0x1,%eax
f01032a6:	39 c8                	cmp    %ecx,%eax
f01032a8:	72 f2                	jb     f010329c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01032aa:	5b                   	pop    %ebx
f01032ab:	5d                   	pop    %ebp
f01032ac:	c3                   	ret    

f01032ad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01032ad:	55                   	push   %ebp
f01032ae:	89 e5                	mov    %esp,%ebp
f01032b0:	57                   	push   %edi
f01032b1:	56                   	push   %esi
f01032b2:	53                   	push   %ebx
f01032b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01032b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01032b9:	eb 03                	jmp    f01032be <strtol+0x11>
		s++;
f01032bb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01032be:	0f b6 01             	movzbl (%ecx),%eax
f01032c1:	3c 20                	cmp    $0x20,%al
f01032c3:	74 f6                	je     f01032bb <strtol+0xe>
f01032c5:	3c 09                	cmp    $0x9,%al
f01032c7:	74 f2                	je     f01032bb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01032c9:	3c 2b                	cmp    $0x2b,%al
f01032cb:	75 0a                	jne    f01032d7 <strtol+0x2a>
		s++;
f01032cd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01032d0:	bf 00 00 00 00       	mov    $0x0,%edi
f01032d5:	eb 11                	jmp    f01032e8 <strtol+0x3b>
f01032d7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01032dc:	3c 2d                	cmp    $0x2d,%al
f01032de:	75 08                	jne    f01032e8 <strtol+0x3b>
		s++, neg = 1;
f01032e0:	83 c1 01             	add    $0x1,%ecx
f01032e3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01032e8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01032ee:	75 15                	jne    f0103305 <strtol+0x58>
f01032f0:	80 39 30             	cmpb   $0x30,(%ecx)
f01032f3:	75 10                	jne    f0103305 <strtol+0x58>
f01032f5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01032f9:	75 7c                	jne    f0103377 <strtol+0xca>
		s += 2, base = 16;
f01032fb:	83 c1 02             	add    $0x2,%ecx
f01032fe:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103303:	eb 16                	jmp    f010331b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103305:	85 db                	test   %ebx,%ebx
f0103307:	75 12                	jne    f010331b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103309:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010330e:	80 39 30             	cmpb   $0x30,(%ecx)
f0103311:	75 08                	jne    f010331b <strtol+0x6e>
		s++, base = 8;
f0103313:	83 c1 01             	add    $0x1,%ecx
f0103316:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010331b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103320:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103323:	0f b6 11             	movzbl (%ecx),%edx
f0103326:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103329:	89 f3                	mov    %esi,%ebx
f010332b:	80 fb 09             	cmp    $0x9,%bl
f010332e:	77 08                	ja     f0103338 <strtol+0x8b>
			dig = *s - '0';
f0103330:	0f be d2             	movsbl %dl,%edx
f0103333:	83 ea 30             	sub    $0x30,%edx
f0103336:	eb 22                	jmp    f010335a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103338:	8d 72 9f             	lea    -0x61(%edx),%esi
f010333b:	89 f3                	mov    %esi,%ebx
f010333d:	80 fb 19             	cmp    $0x19,%bl
f0103340:	77 08                	ja     f010334a <strtol+0x9d>
			dig = *s - 'a' + 10;
f0103342:	0f be d2             	movsbl %dl,%edx
f0103345:	83 ea 57             	sub    $0x57,%edx
f0103348:	eb 10                	jmp    f010335a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010334a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010334d:	89 f3                	mov    %esi,%ebx
f010334f:	80 fb 19             	cmp    $0x19,%bl
f0103352:	77 16                	ja     f010336a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103354:	0f be d2             	movsbl %dl,%edx
f0103357:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010335a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010335d:	7d 0b                	jge    f010336a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010335f:	83 c1 01             	add    $0x1,%ecx
f0103362:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103366:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103368:	eb b9                	jmp    f0103323 <strtol+0x76>

	if (endptr)
f010336a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010336e:	74 0d                	je     f010337d <strtol+0xd0>
		*endptr = (char *) s;
f0103370:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103373:	89 0e                	mov    %ecx,(%esi)
f0103375:	eb 06                	jmp    f010337d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103377:	85 db                	test   %ebx,%ebx
f0103379:	74 98                	je     f0103313 <strtol+0x66>
f010337b:	eb 9e                	jmp    f010331b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010337d:	89 c2                	mov    %eax,%edx
f010337f:	f7 da                	neg    %edx
f0103381:	85 ff                	test   %edi,%edi
f0103383:	0f 45 c2             	cmovne %edx,%eax
}
f0103386:	5b                   	pop    %ebx
f0103387:	5e                   	pop    %esi
f0103388:	5f                   	pop    %edi
f0103389:	5d                   	pop    %ebp
f010338a:	c3                   	ret    
f010338b:	66 90                	xchg   %ax,%ax
f010338d:	66 90                	xchg   %ax,%ax
f010338f:	90                   	nop

f0103390 <__udivdi3>:
f0103390:	55                   	push   %ebp
f0103391:	57                   	push   %edi
f0103392:	56                   	push   %esi
f0103393:	53                   	push   %ebx
f0103394:	83 ec 1c             	sub    $0x1c,%esp
f0103397:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010339b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010339f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01033a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01033a7:	85 f6                	test   %esi,%esi
f01033a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01033ad:	89 ca                	mov    %ecx,%edx
f01033af:	89 f8                	mov    %edi,%eax
f01033b1:	75 3d                	jne    f01033f0 <__udivdi3+0x60>
f01033b3:	39 cf                	cmp    %ecx,%edi
f01033b5:	0f 87 c5 00 00 00    	ja     f0103480 <__udivdi3+0xf0>
f01033bb:	85 ff                	test   %edi,%edi
f01033bd:	89 fd                	mov    %edi,%ebp
f01033bf:	75 0b                	jne    f01033cc <__udivdi3+0x3c>
f01033c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01033c6:	31 d2                	xor    %edx,%edx
f01033c8:	f7 f7                	div    %edi
f01033ca:	89 c5                	mov    %eax,%ebp
f01033cc:	89 c8                	mov    %ecx,%eax
f01033ce:	31 d2                	xor    %edx,%edx
f01033d0:	f7 f5                	div    %ebp
f01033d2:	89 c1                	mov    %eax,%ecx
f01033d4:	89 d8                	mov    %ebx,%eax
f01033d6:	89 cf                	mov    %ecx,%edi
f01033d8:	f7 f5                	div    %ebp
f01033da:	89 c3                	mov    %eax,%ebx
f01033dc:	89 d8                	mov    %ebx,%eax
f01033de:	89 fa                	mov    %edi,%edx
f01033e0:	83 c4 1c             	add    $0x1c,%esp
f01033e3:	5b                   	pop    %ebx
f01033e4:	5e                   	pop    %esi
f01033e5:	5f                   	pop    %edi
f01033e6:	5d                   	pop    %ebp
f01033e7:	c3                   	ret    
f01033e8:	90                   	nop
f01033e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01033f0:	39 ce                	cmp    %ecx,%esi
f01033f2:	77 74                	ja     f0103468 <__udivdi3+0xd8>
f01033f4:	0f bd fe             	bsr    %esi,%edi
f01033f7:	83 f7 1f             	xor    $0x1f,%edi
f01033fa:	0f 84 98 00 00 00    	je     f0103498 <__udivdi3+0x108>
f0103400:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103405:	89 f9                	mov    %edi,%ecx
f0103407:	89 c5                	mov    %eax,%ebp
f0103409:	29 fb                	sub    %edi,%ebx
f010340b:	d3 e6                	shl    %cl,%esi
f010340d:	89 d9                	mov    %ebx,%ecx
f010340f:	d3 ed                	shr    %cl,%ebp
f0103411:	89 f9                	mov    %edi,%ecx
f0103413:	d3 e0                	shl    %cl,%eax
f0103415:	09 ee                	or     %ebp,%esi
f0103417:	89 d9                	mov    %ebx,%ecx
f0103419:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010341d:	89 d5                	mov    %edx,%ebp
f010341f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103423:	d3 ed                	shr    %cl,%ebp
f0103425:	89 f9                	mov    %edi,%ecx
f0103427:	d3 e2                	shl    %cl,%edx
f0103429:	89 d9                	mov    %ebx,%ecx
f010342b:	d3 e8                	shr    %cl,%eax
f010342d:	09 c2                	or     %eax,%edx
f010342f:	89 d0                	mov    %edx,%eax
f0103431:	89 ea                	mov    %ebp,%edx
f0103433:	f7 f6                	div    %esi
f0103435:	89 d5                	mov    %edx,%ebp
f0103437:	89 c3                	mov    %eax,%ebx
f0103439:	f7 64 24 0c          	mull   0xc(%esp)
f010343d:	39 d5                	cmp    %edx,%ebp
f010343f:	72 10                	jb     f0103451 <__udivdi3+0xc1>
f0103441:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103445:	89 f9                	mov    %edi,%ecx
f0103447:	d3 e6                	shl    %cl,%esi
f0103449:	39 c6                	cmp    %eax,%esi
f010344b:	73 07                	jae    f0103454 <__udivdi3+0xc4>
f010344d:	39 d5                	cmp    %edx,%ebp
f010344f:	75 03                	jne    f0103454 <__udivdi3+0xc4>
f0103451:	83 eb 01             	sub    $0x1,%ebx
f0103454:	31 ff                	xor    %edi,%edi
f0103456:	89 d8                	mov    %ebx,%eax
f0103458:	89 fa                	mov    %edi,%edx
f010345a:	83 c4 1c             	add    $0x1c,%esp
f010345d:	5b                   	pop    %ebx
f010345e:	5e                   	pop    %esi
f010345f:	5f                   	pop    %edi
f0103460:	5d                   	pop    %ebp
f0103461:	c3                   	ret    
f0103462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103468:	31 ff                	xor    %edi,%edi
f010346a:	31 db                	xor    %ebx,%ebx
f010346c:	89 d8                	mov    %ebx,%eax
f010346e:	89 fa                	mov    %edi,%edx
f0103470:	83 c4 1c             	add    $0x1c,%esp
f0103473:	5b                   	pop    %ebx
f0103474:	5e                   	pop    %esi
f0103475:	5f                   	pop    %edi
f0103476:	5d                   	pop    %ebp
f0103477:	c3                   	ret    
f0103478:	90                   	nop
f0103479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103480:	89 d8                	mov    %ebx,%eax
f0103482:	f7 f7                	div    %edi
f0103484:	31 ff                	xor    %edi,%edi
f0103486:	89 c3                	mov    %eax,%ebx
f0103488:	89 d8                	mov    %ebx,%eax
f010348a:	89 fa                	mov    %edi,%edx
f010348c:	83 c4 1c             	add    $0x1c,%esp
f010348f:	5b                   	pop    %ebx
f0103490:	5e                   	pop    %esi
f0103491:	5f                   	pop    %edi
f0103492:	5d                   	pop    %ebp
f0103493:	c3                   	ret    
f0103494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103498:	39 ce                	cmp    %ecx,%esi
f010349a:	72 0c                	jb     f01034a8 <__udivdi3+0x118>
f010349c:	31 db                	xor    %ebx,%ebx
f010349e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01034a2:	0f 87 34 ff ff ff    	ja     f01033dc <__udivdi3+0x4c>
f01034a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01034ad:	e9 2a ff ff ff       	jmp    f01033dc <__udivdi3+0x4c>
f01034b2:	66 90                	xchg   %ax,%ax
f01034b4:	66 90                	xchg   %ax,%ax
f01034b6:	66 90                	xchg   %ax,%ax
f01034b8:	66 90                	xchg   %ax,%ax
f01034ba:	66 90                	xchg   %ax,%ax
f01034bc:	66 90                	xchg   %ax,%ax
f01034be:	66 90                	xchg   %ax,%ax

f01034c0 <__umoddi3>:
f01034c0:	55                   	push   %ebp
f01034c1:	57                   	push   %edi
f01034c2:	56                   	push   %esi
f01034c3:	53                   	push   %ebx
f01034c4:	83 ec 1c             	sub    $0x1c,%esp
f01034c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01034cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01034cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01034d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01034d7:	85 d2                	test   %edx,%edx
f01034d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01034dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01034e1:	89 f3                	mov    %esi,%ebx
f01034e3:	89 3c 24             	mov    %edi,(%esp)
f01034e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034ea:	75 1c                	jne    f0103508 <__umoddi3+0x48>
f01034ec:	39 f7                	cmp    %esi,%edi
f01034ee:	76 50                	jbe    f0103540 <__umoddi3+0x80>
f01034f0:	89 c8                	mov    %ecx,%eax
f01034f2:	89 f2                	mov    %esi,%edx
f01034f4:	f7 f7                	div    %edi
f01034f6:	89 d0                	mov    %edx,%eax
f01034f8:	31 d2                	xor    %edx,%edx
f01034fa:	83 c4 1c             	add    $0x1c,%esp
f01034fd:	5b                   	pop    %ebx
f01034fe:	5e                   	pop    %esi
f01034ff:	5f                   	pop    %edi
f0103500:	5d                   	pop    %ebp
f0103501:	c3                   	ret    
f0103502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103508:	39 f2                	cmp    %esi,%edx
f010350a:	89 d0                	mov    %edx,%eax
f010350c:	77 52                	ja     f0103560 <__umoddi3+0xa0>
f010350e:	0f bd ea             	bsr    %edx,%ebp
f0103511:	83 f5 1f             	xor    $0x1f,%ebp
f0103514:	75 5a                	jne    f0103570 <__umoddi3+0xb0>
f0103516:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010351a:	0f 82 e0 00 00 00    	jb     f0103600 <__umoddi3+0x140>
f0103520:	39 0c 24             	cmp    %ecx,(%esp)
f0103523:	0f 86 d7 00 00 00    	jbe    f0103600 <__umoddi3+0x140>
f0103529:	8b 44 24 08          	mov    0x8(%esp),%eax
f010352d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103531:	83 c4 1c             	add    $0x1c,%esp
f0103534:	5b                   	pop    %ebx
f0103535:	5e                   	pop    %esi
f0103536:	5f                   	pop    %edi
f0103537:	5d                   	pop    %ebp
f0103538:	c3                   	ret    
f0103539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103540:	85 ff                	test   %edi,%edi
f0103542:	89 fd                	mov    %edi,%ebp
f0103544:	75 0b                	jne    f0103551 <__umoddi3+0x91>
f0103546:	b8 01 00 00 00       	mov    $0x1,%eax
f010354b:	31 d2                	xor    %edx,%edx
f010354d:	f7 f7                	div    %edi
f010354f:	89 c5                	mov    %eax,%ebp
f0103551:	89 f0                	mov    %esi,%eax
f0103553:	31 d2                	xor    %edx,%edx
f0103555:	f7 f5                	div    %ebp
f0103557:	89 c8                	mov    %ecx,%eax
f0103559:	f7 f5                	div    %ebp
f010355b:	89 d0                	mov    %edx,%eax
f010355d:	eb 99                	jmp    f01034f8 <__umoddi3+0x38>
f010355f:	90                   	nop
f0103560:	89 c8                	mov    %ecx,%eax
f0103562:	89 f2                	mov    %esi,%edx
f0103564:	83 c4 1c             	add    $0x1c,%esp
f0103567:	5b                   	pop    %ebx
f0103568:	5e                   	pop    %esi
f0103569:	5f                   	pop    %edi
f010356a:	5d                   	pop    %ebp
f010356b:	c3                   	ret    
f010356c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103570:	8b 34 24             	mov    (%esp),%esi
f0103573:	bf 20 00 00 00       	mov    $0x20,%edi
f0103578:	89 e9                	mov    %ebp,%ecx
f010357a:	29 ef                	sub    %ebp,%edi
f010357c:	d3 e0                	shl    %cl,%eax
f010357e:	89 f9                	mov    %edi,%ecx
f0103580:	89 f2                	mov    %esi,%edx
f0103582:	d3 ea                	shr    %cl,%edx
f0103584:	89 e9                	mov    %ebp,%ecx
f0103586:	09 c2                	or     %eax,%edx
f0103588:	89 d8                	mov    %ebx,%eax
f010358a:	89 14 24             	mov    %edx,(%esp)
f010358d:	89 f2                	mov    %esi,%edx
f010358f:	d3 e2                	shl    %cl,%edx
f0103591:	89 f9                	mov    %edi,%ecx
f0103593:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103597:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010359b:	d3 e8                	shr    %cl,%eax
f010359d:	89 e9                	mov    %ebp,%ecx
f010359f:	89 c6                	mov    %eax,%esi
f01035a1:	d3 e3                	shl    %cl,%ebx
f01035a3:	89 f9                	mov    %edi,%ecx
f01035a5:	89 d0                	mov    %edx,%eax
f01035a7:	d3 e8                	shr    %cl,%eax
f01035a9:	89 e9                	mov    %ebp,%ecx
f01035ab:	09 d8                	or     %ebx,%eax
f01035ad:	89 d3                	mov    %edx,%ebx
f01035af:	89 f2                	mov    %esi,%edx
f01035b1:	f7 34 24             	divl   (%esp)
f01035b4:	89 d6                	mov    %edx,%esi
f01035b6:	d3 e3                	shl    %cl,%ebx
f01035b8:	f7 64 24 04          	mull   0x4(%esp)
f01035bc:	39 d6                	cmp    %edx,%esi
f01035be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035c2:	89 d1                	mov    %edx,%ecx
f01035c4:	89 c3                	mov    %eax,%ebx
f01035c6:	72 08                	jb     f01035d0 <__umoddi3+0x110>
f01035c8:	75 11                	jne    f01035db <__umoddi3+0x11b>
f01035ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01035ce:	73 0b                	jae    f01035db <__umoddi3+0x11b>
f01035d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01035d4:	1b 14 24             	sbb    (%esp),%edx
f01035d7:	89 d1                	mov    %edx,%ecx
f01035d9:	89 c3                	mov    %eax,%ebx
f01035db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01035df:	29 da                	sub    %ebx,%edx
f01035e1:	19 ce                	sbb    %ecx,%esi
f01035e3:	89 f9                	mov    %edi,%ecx
f01035e5:	89 f0                	mov    %esi,%eax
f01035e7:	d3 e0                	shl    %cl,%eax
f01035e9:	89 e9                	mov    %ebp,%ecx
f01035eb:	d3 ea                	shr    %cl,%edx
f01035ed:	89 e9                	mov    %ebp,%ecx
f01035ef:	d3 ee                	shr    %cl,%esi
f01035f1:	09 d0                	or     %edx,%eax
f01035f3:	89 f2                	mov    %esi,%edx
f01035f5:	83 c4 1c             	add    $0x1c,%esp
f01035f8:	5b                   	pop    %ebx
f01035f9:	5e                   	pop    %esi
f01035fa:	5f                   	pop    %edi
f01035fb:	5d                   	pop    %ebp
f01035fc:	c3                   	ret    
f01035fd:	8d 76 00             	lea    0x0(%esi),%esi
f0103600:	29 f9                	sub    %edi,%ecx
f0103602:	19 d6                	sbb    %edx,%esi
f0103604:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103608:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010360c:	e9 18 ff ff ff       	jmp    f0103529 <__umoddi3+0x69>
