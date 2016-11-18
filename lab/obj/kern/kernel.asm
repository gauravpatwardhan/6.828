
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

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
f0100067:	e8 f9 06 00 00       	call   f0100765 <mon_backtrace>
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
f0100077:	b8 70 79 11 f0       	mov    $0xf0117970,%eax
f010007c:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100081:	50                   	push   %eax
f0100082:	6a 00                	push   $0x0
f0100084:	68 00 73 11 f0       	push   $0xf0117300
f0100089:	e8 0b 31 00 00       	call   f0103199 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010008e:	e8 a0 04 00 00       	call   f0100533 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100093:	83 c4 08             	add    $0x8,%esp
f0100096:	68 ac 1a 00 00       	push   $0x1aac
f010009b:	68 40 36 10 f0       	push   $0xf0103640
f01000a0:	e8 3b 26 00 00       	call   f01026e0 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000a5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ac:	e8 8f ff ff ff       	call   f0100040 <test_backtrace>

	// Lab 2 memory initialization functions
	cprintf("Entering mem_init function\n");
f01000b1:	c7 04 24 5b 36 10 f0 	movl   $0xf010365b,(%esp)
f01000b8:	e8 23 26 00 00       	call   f01026e0 <cprintf>
	mem_init();
f01000bd:	e8 b6 0f 00 00       	call   f0101078 <mem_init>
f01000c2:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000c5:	83 ec 0c             	sub    $0xc,%esp
f01000c8:	6a 00                	push   $0x0
f01000ca:	e8 64 07 00 00       	call   f0100833 <monitor>
f01000cf:	83 c4 10             	add    $0x10,%esp
f01000d2:	eb f1                	jmp    f01000c5 <i386_init+0x54>

f01000d4 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000d4:	55                   	push   %ebp
f01000d5:	89 e5                	mov    %esp,%ebp
f01000d7:	56                   	push   %esi
f01000d8:	53                   	push   %ebx
f01000d9:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000dc:	83 3d 60 79 11 f0 00 	cmpl   $0x0,0xf0117960
f01000e3:	75 37                	jne    f010011c <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000e5:	89 35 60 79 11 f0    	mov    %esi,0xf0117960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000eb:	fa                   	cli    
f01000ec:	fc                   	cld    

	va_start(ap, fmt);
f01000ed:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000f0:	83 ec 04             	sub    $0x4,%esp
f01000f3:	ff 75 0c             	pushl  0xc(%ebp)
f01000f6:	ff 75 08             	pushl  0x8(%ebp)
f01000f9:	68 77 36 10 f0       	push   $0xf0103677
f01000fe:	e8 dd 25 00 00       	call   f01026e0 <cprintf>
	vcprintf(fmt, ap);
f0100103:	83 c4 08             	add    $0x8,%esp
f0100106:	53                   	push   %ebx
f0100107:	56                   	push   %esi
f0100108:	e8 ad 25 00 00       	call   f01026ba <vcprintf>
	cprintf("\n");
f010010d:	c7 04 24 f4 44 10 f0 	movl   $0xf01044f4,(%esp)
f0100114:	e8 c7 25 00 00       	call   f01026e0 <cprintf>
	va_end(ap);
f0100119:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011c:	83 ec 0c             	sub    $0xc,%esp
f010011f:	6a 00                	push   $0x0
f0100121:	e8 0d 07 00 00       	call   f0100833 <monitor>
f0100126:	83 c4 10             	add    $0x10,%esp
f0100129:	eb f1                	jmp    f010011c <_panic+0x48>

f010012b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010012b:	55                   	push   %ebp
f010012c:	89 e5                	mov    %esp,%ebp
f010012e:	53                   	push   %ebx
f010012f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100132:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100135:	ff 75 0c             	pushl  0xc(%ebp)
f0100138:	ff 75 08             	pushl  0x8(%ebp)
f010013b:	68 8f 36 10 f0       	push   $0xf010368f
f0100140:	e8 9b 25 00 00       	call   f01026e0 <cprintf>
	vcprintf(fmt, ap);
f0100145:	83 c4 08             	add    $0x8,%esp
f0100148:	53                   	push   %ebx
f0100149:	ff 75 10             	pushl  0x10(%ebp)
f010014c:	e8 69 25 00 00       	call   f01026ba <vcprintf>
	cprintf("\n");
f0100151:	c7 04 24 f4 44 10 f0 	movl   $0xf01044f4,(%esp)
f0100158:	e8 83 25 00 00       	call   f01026e0 <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100163:	c9                   	leave  
f0100164:	c3                   	ret    

f0100165 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100165:	55                   	push   %ebp
f0100166:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100168:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010016d:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010016e:	a8 01                	test   $0x1,%al
f0100170:	74 0b                	je     f010017d <serial_proc_data+0x18>
f0100172:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100177:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100178:	0f b6 c0             	movzbl %al,%eax
f010017b:	eb 05                	jmp    f0100182 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010017d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100182:	5d                   	pop    %ebp
f0100183:	c3                   	ret    

f0100184 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100184:	55                   	push   %ebp
f0100185:	89 e5                	mov    %esp,%ebp
f0100187:	53                   	push   %ebx
f0100188:	83 ec 04             	sub    $0x4,%esp
f010018b:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010018d:	eb 2b                	jmp    f01001ba <cons_intr+0x36>
		if (c == 0)
f010018f:	85 c0                	test   %eax,%eax
f0100191:	74 27                	je     f01001ba <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100193:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f0100199:	8d 51 01             	lea    0x1(%ecx),%edx
f010019c:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f01001a2:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001a8:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001ae:	75 0a                	jne    f01001ba <cons_intr+0x36>
			cons.wpos = 0;
f01001b0:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f01001b7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001ba:	ff d3                	call   *%ebx
f01001bc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001bf:	75 ce                	jne    f010018f <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001c1:	83 c4 04             	add    $0x4,%esp
f01001c4:	5b                   	pop    %ebx
f01001c5:	5d                   	pop    %ebp
f01001c6:	c3                   	ret    

f01001c7 <kbd_proc_data>:
f01001c7:	ba 64 00 00 00       	mov    $0x64,%edx
f01001cc:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001cd:	a8 01                	test   $0x1,%al
f01001cf:	0f 84 f0 00 00 00    	je     f01002c5 <kbd_proc_data+0xfe>
f01001d5:	ba 60 00 00 00       	mov    $0x60,%edx
f01001da:	ec                   	in     (%dx),%al
f01001db:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001dd:	3c e0                	cmp    $0xe0,%al
f01001df:	75 0d                	jne    f01001ee <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001e1:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f01001e8:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001ed:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	53                   	push   %ebx
f01001f2:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001f5:	84 c0                	test   %al,%al
f01001f7:	79 36                	jns    f010022f <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001f9:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001ff:	89 cb                	mov    %ecx,%ebx
f0100201:	83 e3 40             	and    $0x40,%ebx
f0100204:	83 e0 7f             	and    $0x7f,%eax
f0100207:	85 db                	test   %ebx,%ebx
f0100209:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010020c:	0f b6 d2             	movzbl %dl,%edx
f010020f:	0f b6 82 00 38 10 f0 	movzbl -0xfefc800(%edx),%eax
f0100216:	83 c8 40             	or     $0x40,%eax
f0100219:	0f b6 c0             	movzbl %al,%eax
f010021c:	f7 d0                	not    %eax
f010021e:	21 c8                	and    %ecx,%eax
f0100220:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f0100225:	b8 00 00 00 00       	mov    $0x0,%eax
f010022a:	e9 9e 00 00 00       	jmp    f01002cd <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010022f:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f0100235:	f6 c1 40             	test   $0x40,%cl
f0100238:	74 0e                	je     f0100248 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010023a:	83 c8 80             	or     $0xffffff80,%eax
f010023d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010023f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100242:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f0100248:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010024b:	0f b6 82 00 38 10 f0 	movzbl -0xfefc800(%edx),%eax
f0100252:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100258:	0f b6 8a 00 37 10 f0 	movzbl -0xfefc900(%edx),%ecx
f010025f:	31 c8                	xor    %ecx,%eax
f0100261:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100266:	89 c1                	mov    %eax,%ecx
f0100268:	83 e1 03             	and    $0x3,%ecx
f010026b:	8b 0c 8d e0 36 10 f0 	mov    -0xfefc920(,%ecx,4),%ecx
f0100272:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100276:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100279:	a8 08                	test   $0x8,%al
f010027b:	74 1b                	je     f0100298 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010027d:	89 da                	mov    %ebx,%edx
f010027f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100282:	83 f9 19             	cmp    $0x19,%ecx
f0100285:	77 05                	ja     f010028c <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100287:	83 eb 20             	sub    $0x20,%ebx
f010028a:	eb 0c                	jmp    f0100298 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010028c:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010028f:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100292:	83 fa 19             	cmp    $0x19,%edx
f0100295:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100298:	f7 d0                	not    %eax
f010029a:	a8 06                	test   $0x6,%al
f010029c:	75 2d                	jne    f01002cb <kbd_proc_data+0x104>
f010029e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002a4:	75 25                	jne    f01002cb <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002a6:	83 ec 0c             	sub    $0xc,%esp
f01002a9:	68 a9 36 10 f0       	push   $0xf01036a9
f01002ae:	e8 2d 24 00 00       	call   f01026e0 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002b3:	ba 92 00 00 00       	mov    $0x92,%edx
f01002b8:	b8 03 00 00 00       	mov    $0x3,%eax
f01002bd:	ee                   	out    %al,(%dx)
f01002be:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002c1:	89 d8                	mov    %ebx,%eax
f01002c3:	eb 08                	jmp    f01002cd <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ca:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002cb:	89 d8                	mov    %ebx,%eax
}
f01002cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002d0:	c9                   	leave  
f01002d1:	c3                   	ret    

f01002d2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002d2:	55                   	push   %ebp
f01002d3:	89 e5                	mov    %esp,%ebp
f01002d5:	57                   	push   %edi
f01002d6:	56                   	push   %esi
f01002d7:	53                   	push   %ebx
f01002d8:	83 ec 1c             	sub    $0x1c,%esp
f01002db:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002dd:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e2:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002e7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ec:	eb 09                	jmp    f01002f7 <cons_putc+0x25>
f01002ee:	89 ca                	mov    %ecx,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002f4:	83 c3 01             	add    $0x1,%ebx
f01002f7:	89 f2                	mov    %esi,%edx
f01002f9:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002fa:	a8 20                	test   $0x20,%al
f01002fc:	75 08                	jne    f0100306 <cons_putc+0x34>
f01002fe:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100304:	7e e8                	jle    f01002ee <cons_putc+0x1c>
f0100306:	89 f8                	mov    %edi,%eax
f0100308:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010030b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100310:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100311:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100316:	be 79 03 00 00       	mov    $0x379,%esi
f010031b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100320:	eb 09                	jmp    f010032b <cons_putc+0x59>
f0100322:	89 ca                	mov    %ecx,%edx
f0100324:	ec                   	in     (%dx),%al
f0100325:	ec                   	in     (%dx),%al
f0100326:	ec                   	in     (%dx),%al
f0100327:	ec                   	in     (%dx),%al
f0100328:	83 c3 01             	add    $0x1,%ebx
f010032b:	89 f2                	mov    %esi,%edx
f010032d:	ec                   	in     (%dx),%al
f010032e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100334:	7f 04                	jg     f010033a <cons_putc+0x68>
f0100336:	84 c0                	test   %al,%al
f0100338:	79 e8                	jns    f0100322 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010033a:	ba 78 03 00 00       	mov    $0x378,%edx
f010033f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100343:	ee                   	out    %al,(%dx)
f0100344:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100349:	b8 0d 00 00 00       	mov    $0xd,%eax
f010034e:	ee                   	out    %al,(%dx)
f010034f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100354:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100355:	89 fa                	mov    %edi,%edx
f0100357:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010035d:	89 f8                	mov    %edi,%eax
f010035f:	80 cc 07             	or     $0x7,%ah
f0100362:	85 d2                	test   %edx,%edx
f0100364:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100367:	89 f8                	mov    %edi,%eax
f0100369:	0f b6 c0             	movzbl %al,%eax
f010036c:	83 f8 09             	cmp    $0x9,%eax
f010036f:	74 74                	je     f01003e5 <cons_putc+0x113>
f0100371:	83 f8 09             	cmp    $0x9,%eax
f0100374:	7f 0a                	jg     f0100380 <cons_putc+0xae>
f0100376:	83 f8 08             	cmp    $0x8,%eax
f0100379:	74 14                	je     f010038f <cons_putc+0xbd>
f010037b:	e9 99 00 00 00       	jmp    f0100419 <cons_putc+0x147>
f0100380:	83 f8 0a             	cmp    $0xa,%eax
f0100383:	74 3a                	je     f01003bf <cons_putc+0xed>
f0100385:	83 f8 0d             	cmp    $0xd,%eax
f0100388:	74 3d                	je     f01003c7 <cons_putc+0xf5>
f010038a:	e9 8a 00 00 00       	jmp    f0100419 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010038f:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100396:	66 85 c0             	test   %ax,%ax
f0100399:	0f 84 e6 00 00 00    	je     f0100485 <cons_putc+0x1b3>
			crt_pos--;
f010039f:	83 e8 01             	sub    $0x1,%eax
f01003a2:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003a8:	0f b7 c0             	movzwl %ax,%eax
f01003ab:	66 81 e7 00 ff       	and    $0xff00,%di
f01003b0:	83 cf 20             	or     $0x20,%edi
f01003b3:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01003b9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003bd:	eb 78                	jmp    f0100437 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003bf:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f01003c6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003c7:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003ce:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003d4:	c1 e8 16             	shr    $0x16,%eax
f01003d7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003da:	c1 e0 04             	shl    $0x4,%eax
f01003dd:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f01003e3:	eb 52                	jmp    f0100437 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ea:	e8 e3 fe ff ff       	call   f01002d2 <cons_putc>
		cons_putc(' ');
f01003ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f4:	e8 d9 fe ff ff       	call   f01002d2 <cons_putc>
		cons_putc(' ');
f01003f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fe:	e8 cf fe ff ff       	call   f01002d2 <cons_putc>
		cons_putc(' ');
f0100403:	b8 20 00 00 00       	mov    $0x20,%eax
f0100408:	e8 c5 fe ff ff       	call   f01002d2 <cons_putc>
		cons_putc(' ');
f010040d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100412:	e8 bb fe ff ff       	call   f01002d2 <cons_putc>
f0100417:	eb 1e                	jmp    f0100437 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100419:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100420:	8d 50 01             	lea    0x1(%eax),%edx
f0100423:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f010042a:	0f b7 c0             	movzwl %ax,%eax
f010042d:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100433:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100437:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f010043e:	cf 07 
f0100440:	76 43                	jbe    f0100485 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100442:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f0100447:	83 ec 04             	sub    $0x4,%esp
f010044a:	68 00 0f 00 00       	push   $0xf00
f010044f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100455:	52                   	push   %edx
f0100456:	50                   	push   %eax
f0100457:	e8 8a 2d 00 00       	call   f01031e6 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010045c:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100462:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100468:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010046e:	83 c4 10             	add    $0x10,%esp
f0100471:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100476:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100479:	39 d0                	cmp    %edx,%eax
f010047b:	75 f4                	jne    f0100471 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010047d:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f0100484:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100485:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f010048b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100490:	89 ca                	mov    %ecx,%edx
f0100492:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100493:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f010049a:	8d 71 01             	lea    0x1(%ecx),%esi
f010049d:	89 d8                	mov    %ebx,%eax
f010049f:	66 c1 e8 08          	shr    $0x8,%ax
f01004a3:	89 f2                	mov    %esi,%edx
f01004a5:	ee                   	out    %al,(%dx)
f01004a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ab:	89 ca                	mov    %ecx,%edx
f01004ad:	ee                   	out    %al,(%dx)
f01004ae:	89 d8                	mov    %ebx,%eax
f01004b0:	89 f2                	mov    %esi,%edx
f01004b2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004b6:	5b                   	pop    %ebx
f01004b7:	5e                   	pop    %esi
f01004b8:	5f                   	pop    %edi
f01004b9:	5d                   	pop    %ebp
f01004ba:	c3                   	ret    

f01004bb <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004bb:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f01004c2:	74 11                	je     f01004d5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004c4:	55                   	push   %ebp
f01004c5:	89 e5                	mov    %esp,%ebp
f01004c7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ca:	b8 65 01 10 f0       	mov    $0xf0100165,%eax
f01004cf:	e8 b0 fc ff ff       	call   f0100184 <cons_intr>
}
f01004d4:	c9                   	leave  
f01004d5:	f3 c3                	repz ret 

f01004d7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004d7:	55                   	push   %ebp
f01004d8:	89 e5                	mov    %esp,%ebp
f01004da:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004dd:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
f01004e2:	e8 9d fc ff ff       	call   f0100184 <cons_intr>
}
f01004e7:	c9                   	leave  
f01004e8:	c3                   	ret    

f01004e9 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004e9:	55                   	push   %ebp
f01004ea:	89 e5                	mov    %esp,%ebp
f01004ec:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004ef:	e8 c7 ff ff ff       	call   f01004bb <serial_intr>
	kbd_intr();
f01004f4:	e8 de ff ff ff       	call   f01004d7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004f9:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f01004fe:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f0100504:	74 26                	je     f010052c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100506:	8d 50 01             	lea    0x1(%eax),%edx
f0100509:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f010050f:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100516:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100518:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010051e:	75 11                	jne    f0100531 <cons_getc+0x48>
			cons.rpos = 0;
f0100520:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f0100527:	00 00 00 
f010052a:	eb 05                	jmp    f0100531 <cons_getc+0x48>
		return c;
	}
	return 0;
f010052c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100531:	c9                   	leave  
f0100532:	c3                   	ret    

f0100533 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100533:	55                   	push   %ebp
f0100534:	89 e5                	mov    %esp,%ebp
f0100536:	57                   	push   %edi
f0100537:	56                   	push   %esi
f0100538:	53                   	push   %ebx
f0100539:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010053c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100543:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010054a:	5a a5 
	if (*cp != 0xA55A) {
f010054c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100553:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100557:	74 11                	je     f010056a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100559:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f0100560:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100563:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100568:	eb 16                	jmp    f0100580 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010056a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100571:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f0100578:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010057b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100580:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
f0100586:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058b:	89 fa                	mov    %edi,%edx
f010058d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010058e:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100591:	89 da                	mov    %ebx,%edx
f0100593:	ec                   	in     (%dx),%al
f0100594:	0f b6 c8             	movzbl %al,%ecx
f0100597:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010059f:	89 fa                	mov    %edi,%edx
f01005a1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a2:	89 da                	mov    %ebx,%edx
f01005a4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005a5:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	crt_pos = pos;
f01005ab:	0f b6 c0             	movzbl %al,%eax
f01005ae:	09 c8                	or     %ecx,%eax
f01005b0:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005b6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c0:	89 f2                	mov    %esi,%edx
f01005c2:	ee                   	out    %al,(%dx)
f01005c3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005c8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005cd:	ee                   	out    %al,(%dx)
f01005ce:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005d3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005d8:	89 da                	mov    %ebx,%edx
f01005da:	ee                   	out    %al,(%dx)
f01005db:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e5:	ee                   	out    %al,(%dx)
f01005e6:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005eb:	b8 03 00 00 00       	mov    $0x3,%eax
f01005f0:	ee                   	out    %al,(%dx)
f01005f1:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01005fb:	ee                   	out    %al,(%dx)
f01005fc:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100601:	b8 01 00 00 00       	mov    $0x1,%eax
f0100606:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100607:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010060c:	ec                   	in     (%dx),%al
f010060d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010060f:	3c ff                	cmp    $0xff,%al
f0100611:	0f 95 05 34 75 11 f0 	setne  0xf0117534
f0100618:	89 f2                	mov    %esi,%edx
f010061a:	ec                   	in     (%dx),%al
f010061b:	89 da                	mov    %ebx,%edx
f010061d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010061e:	80 f9 ff             	cmp    $0xff,%cl
f0100621:	75 10                	jne    f0100633 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100623:	83 ec 0c             	sub    $0xc,%esp
f0100626:	68 b5 36 10 f0       	push   $0xf01036b5
f010062b:	e8 b0 20 00 00       	call   f01026e0 <cprintf>
f0100630:	83 c4 10             	add    $0x10,%esp
}
f0100633:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100636:	5b                   	pop    %ebx
f0100637:	5e                   	pop    %esi
f0100638:	5f                   	pop    %edi
f0100639:	5d                   	pop    %ebp
f010063a:	c3                   	ret    

f010063b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010063b:	55                   	push   %ebp
f010063c:	89 e5                	mov    %esp,%ebp
f010063e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100641:	8b 45 08             	mov    0x8(%ebp),%eax
f0100644:	e8 89 fc ff ff       	call   f01002d2 <cons_putc>
}
f0100649:	c9                   	leave  
f010064a:	c3                   	ret    

f010064b <getchar>:

int
getchar(void)
{
f010064b:	55                   	push   %ebp
f010064c:	89 e5                	mov    %esp,%ebp
f010064e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100651:	e8 93 fe ff ff       	call   f01004e9 <cons_getc>
f0100656:	85 c0                	test   %eax,%eax
f0100658:	74 f7                	je     f0100651 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010065a:	c9                   	leave  
f010065b:	c3                   	ret    

f010065c <iscons>:

int
iscons(int fdnum)
{
f010065c:	55                   	push   %ebp
f010065d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010065f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100664:	5d                   	pop    %ebp
f0100665:	c3                   	ret    

f0100666 <mon_help>:



int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100666:	55                   	push   %ebp
f0100667:	89 e5                	mov    %esp,%ebp
f0100669:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010066c:	68 00 39 10 f0       	push   $0xf0103900
f0100671:	68 1e 39 10 f0       	push   $0xf010391e
f0100676:	68 23 39 10 f0       	push   $0xf0103923
f010067b:	e8 60 20 00 00       	call   f01026e0 <cprintf>
f0100680:	83 c4 0c             	add    $0xc,%esp
f0100683:	68 d8 39 10 f0       	push   $0xf01039d8
f0100688:	68 2c 39 10 f0       	push   $0xf010392c
f010068d:	68 23 39 10 f0       	push   $0xf0103923
f0100692:	e8 49 20 00 00       	call   f01026e0 <cprintf>
f0100697:	83 c4 0c             	add    $0xc,%esp
f010069a:	68 35 39 10 f0       	push   $0xf0103935
f010069f:	68 4c 39 10 f0       	push   $0xf010394c
f01006a4:	68 23 39 10 f0       	push   $0xf0103923
f01006a9:	e8 32 20 00 00       	call   f01026e0 <cprintf>
	return 0;
}
f01006ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01006b3:	c9                   	leave  
f01006b4:	c3                   	ret    

f01006b5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006b5:	55                   	push   %ebp
f01006b6:	89 e5                	mov    %esp,%ebp
f01006b8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006bb:	68 56 39 10 f0       	push   $0xf0103956
f01006c0:	e8 1b 20 00 00       	call   f01026e0 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006c5:	83 c4 08             	add    $0x8,%esp
f01006c8:	68 0c 00 10 00       	push   $0x10000c
f01006cd:	68 00 3a 10 f0       	push   $0xf0103a00
f01006d2:	e8 09 20 00 00       	call   f01026e0 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006d7:	83 c4 0c             	add    $0xc,%esp
f01006da:	68 0c 00 10 00       	push   $0x10000c
f01006df:	68 0c 00 10 f0       	push   $0xf010000c
f01006e4:	68 28 3a 10 f0       	push   $0xf0103a28
f01006e9:	e8 f2 1f 00 00       	call   f01026e0 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ee:	83 c4 0c             	add    $0xc,%esp
f01006f1:	68 21 36 10 00       	push   $0x103621
f01006f6:	68 21 36 10 f0       	push   $0xf0103621
f01006fb:	68 4c 3a 10 f0       	push   $0xf0103a4c
f0100700:	e8 db 1f 00 00       	call   f01026e0 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100705:	83 c4 0c             	add    $0xc,%esp
f0100708:	68 00 73 11 00       	push   $0x117300
f010070d:	68 00 73 11 f0       	push   $0xf0117300
f0100712:	68 70 3a 10 f0       	push   $0xf0103a70
f0100717:	e8 c4 1f 00 00       	call   f01026e0 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010071c:	83 c4 0c             	add    $0xc,%esp
f010071f:	68 70 79 11 00       	push   $0x117970
f0100724:	68 70 79 11 f0       	push   $0xf0117970
f0100729:	68 94 3a 10 f0       	push   $0xf0103a94
f010072e:	e8 ad 1f 00 00       	call   f01026e0 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100733:	b8 6f 7d 11 f0       	mov    $0xf0117d6f,%eax
f0100738:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010073d:	83 c4 08             	add    $0x8,%esp
f0100740:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100745:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010074b:	85 c0                	test   %eax,%eax
f010074d:	0f 48 c2             	cmovs  %edx,%eax
f0100750:	c1 f8 0a             	sar    $0xa,%eax
f0100753:	50                   	push   %eax
f0100754:	68 b8 3a 10 f0       	push   $0xf0103ab8
f0100759:	e8 82 1f 00 00       	call   f01026e0 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010075e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100763:	c9                   	leave  
f0100764:	c3                   	ret    

f0100765 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	57                   	push   %edi
f0100769:	56                   	push   %esi
f010076a:	53                   	push   %ebx
f010076b:	83 ec 48             	sub    $0x48,%esp
	// Your code here.
	
	//basic stack backtrace code
	cprintf("Stack backtrace:\n");
f010076e:	68 6f 39 10 f0       	push   $0xf010396f
f0100773:	e8 68 1f 00 00       	call   f01026e0 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100778:	89 eb                	mov    %ebp,%ebx
	uintptr_t ebp_current_local = read_ebp();
	uintptr_t eip_current_local = 0;
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};
f010077a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100781:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100788:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010078f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100796:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
f010079d:	83 c4 0c             	add    $0xc,%esp
f01007a0:	6a 18                	push   $0x18
f01007a2:	6a 00                	push   $0x0
f01007a4:	8d 45 bc             	lea    -0x44(%ebp),%eax
f01007a7:	50                   	push   %eax
f01007a8:	e8 ec 29 00 00       	call   f0103199 <memset>
	while (ebp_current_local != 0){
f01007ad:	83 c4 10             	add    $0x10,%esp
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f01007b0:	8d 7d bc             	lea    -0x44(%ebp),%edi
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f01007b3:	eb 6d                	jmp    f0100822 <mon_backtrace+0xbd>
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
f01007b5:	8b 73 04             	mov    0x4(%ebx),%esi
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007b8:	b8 00 00 00 00       	mov    $0x0,%eax
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
f01007bd:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01007c1:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007c5:	83 c0 01             	add    $0x1,%eax
f01007c8:	83 f8 05             	cmp    $0x5,%eax
f01007cb:	75 f0                	jne    f01007bd <mon_backtrace+0x58>
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
f01007cd:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007d0:	ff 75 e0             	pushl  -0x20(%ebp)
f01007d3:	ff 75 dc             	pushl  -0x24(%ebp)
f01007d6:	ff 75 d8             	pushl  -0x28(%ebp)
f01007d9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007dc:	56                   	push   %esi
f01007dd:	53                   	push   %ebx
f01007de:	68 e4 3a 10 f0       	push   $0xf0103ae4
f01007e3:	e8 f8 1e 00 00       	call   f01026e0 <cprintf>
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f01007e8:	83 c4 18             	add    $0x18,%esp
f01007eb:	57                   	push   %edi
f01007ec:	56                   	push   %esi
f01007ed:	e8 f8 1f 00 00       	call   f01027ea <debuginfo_eip>
f01007f2:	83 c4 10             	add    $0x10,%esp
f01007f5:	85 c0                	test   %eax,%eax
f01007f7:	75 20                	jne    f0100819 <mon_backtrace+0xb4>
				cprintf("        %s:%d: %.*s+%d\n", eipinfo.eip_file, eipinfo.eip_line, 
f01007f9:	83 ec 08             	sub    $0x8,%esp
f01007fc:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007ff:	56                   	push   %esi
f0100800:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100803:	ff 75 c8             	pushl  -0x38(%ebp)
f0100806:	ff 75 c0             	pushl  -0x40(%ebp)
f0100809:	ff 75 bc             	pushl  -0x44(%ebp)
f010080c:	68 81 39 10 f0       	push   $0xf0103981
f0100811:	e8 ca 1e 00 00       	call   f01026e0 <cprintf>
f0100816:	83 c4 20             	add    $0x20,%esp
						eipinfo.eip_fn_namelen, eipinfo.eip_fn_name, eip_current_local-eipinfo.eip_fn_addr);

		}
		// point the ebp to the next ebp using the current ebp value pushed on stack	
		ebp_current_local = *(uintptr_t *)(ebp_current_local);
f0100819:	8b 1b                	mov    (%ebx),%ebx
f010081b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f0100822:	85 db                	test   %ebx,%ebx
f0100824:	75 8f                	jne    f01007b5 <mon_backtrace+0x50>
		for ( i = 0; i < MAX_ARGS_PASSED; i++){
			args_arr[0] = 0;
		}
	}
	return 0;
}
f0100826:	b8 00 00 00 00       	mov    $0x0,%eax
f010082b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010082e:	5b                   	pop    %ebx
f010082f:	5e                   	pop    %esi
f0100830:	5f                   	pop    %edi
f0100831:	5d                   	pop    %ebp
f0100832:	c3                   	ret    

f0100833 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100833:	55                   	push   %ebp
f0100834:	89 e5                	mov    %esp,%ebp
f0100836:	57                   	push   %edi
f0100837:	56                   	push   %esi
f0100838:	53                   	push   %ebx
f0100839:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010083c:	68 18 3b 10 f0       	push   $0xf0103b18
f0100841:	e8 9a 1e 00 00       	call   f01026e0 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100846:	c7 04 24 3c 3b 10 f0 	movl   $0xf0103b3c,(%esp)
f010084d:	e8 8e 1e 00 00       	call   f01026e0 <cprintf>
f0100852:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100855:	83 ec 0c             	sub    $0xc,%esp
f0100858:	68 99 39 10 f0       	push   $0xf0103999
f010085d:	e8 e0 26 00 00       	call   f0102f42 <readline>
f0100862:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100864:	83 c4 10             	add    $0x10,%esp
f0100867:	85 c0                	test   %eax,%eax
f0100869:	74 ea                	je     f0100855 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010086b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100872:	be 00 00 00 00       	mov    $0x0,%esi
f0100877:	eb 0a                	jmp    f0100883 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100879:	c6 03 00             	movb   $0x0,(%ebx)
f010087c:	89 f7                	mov    %esi,%edi
f010087e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100881:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100883:	0f b6 03             	movzbl (%ebx),%eax
f0100886:	84 c0                	test   %al,%al
f0100888:	74 63                	je     f01008ed <monitor+0xba>
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	0f be c0             	movsbl %al,%eax
f0100890:	50                   	push   %eax
f0100891:	68 9d 39 10 f0       	push   $0xf010399d
f0100896:	e8 c1 28 00 00       	call   f010315c <strchr>
f010089b:	83 c4 10             	add    $0x10,%esp
f010089e:	85 c0                	test   %eax,%eax
f01008a0:	75 d7                	jne    f0100879 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008a2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008a5:	74 46                	je     f01008ed <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008a7:	83 fe 0f             	cmp    $0xf,%esi
f01008aa:	75 14                	jne    f01008c0 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008ac:	83 ec 08             	sub    $0x8,%esp
f01008af:	6a 10                	push   $0x10
f01008b1:	68 a2 39 10 f0       	push   $0xf01039a2
f01008b6:	e8 25 1e 00 00       	call   f01026e0 <cprintf>
f01008bb:	83 c4 10             	add    $0x10,%esp
f01008be:	eb 95                	jmp    f0100855 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008c0:	8d 7e 01             	lea    0x1(%esi),%edi
f01008c3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008c7:	eb 03                	jmp    f01008cc <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008c9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008cc:	0f b6 03             	movzbl (%ebx),%eax
f01008cf:	84 c0                	test   %al,%al
f01008d1:	74 ae                	je     f0100881 <monitor+0x4e>
f01008d3:	83 ec 08             	sub    $0x8,%esp
f01008d6:	0f be c0             	movsbl %al,%eax
f01008d9:	50                   	push   %eax
f01008da:	68 9d 39 10 f0       	push   $0xf010399d
f01008df:	e8 78 28 00 00       	call   f010315c <strchr>
f01008e4:	83 c4 10             	add    $0x10,%esp
f01008e7:	85 c0                	test   %eax,%eax
f01008e9:	74 de                	je     f01008c9 <monitor+0x96>
f01008eb:	eb 94                	jmp    f0100881 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008ed:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008f4:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008f5:	85 f6                	test   %esi,%esi
f01008f7:	0f 84 58 ff ff ff    	je     f0100855 <monitor+0x22>
f01008fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100902:	83 ec 08             	sub    $0x8,%esp
f0100905:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100908:	ff 34 85 80 3b 10 f0 	pushl  -0xfefc480(,%eax,4)
f010090f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100912:	e8 e7 27 00 00       	call   f01030fe <strcmp>
f0100917:	83 c4 10             	add    $0x10,%esp
f010091a:	85 c0                	test   %eax,%eax
f010091c:	75 21                	jne    f010093f <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f010091e:	83 ec 04             	sub    $0x4,%esp
f0100921:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100924:	ff 75 08             	pushl  0x8(%ebp)
f0100927:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010092a:	52                   	push   %edx
f010092b:	56                   	push   %esi
f010092c:	ff 14 85 88 3b 10 f0 	call   *-0xfefc478(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100933:	83 c4 10             	add    $0x10,%esp
f0100936:	85 c0                	test   %eax,%eax
f0100938:	78 25                	js     f010095f <monitor+0x12c>
f010093a:	e9 16 ff ff ff       	jmp    f0100855 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010093f:	83 c3 01             	add    $0x1,%ebx
f0100942:	83 fb 03             	cmp    $0x3,%ebx
f0100945:	75 bb                	jne    f0100902 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100947:	83 ec 08             	sub    $0x8,%esp
f010094a:	ff 75 a8             	pushl  -0x58(%ebp)
f010094d:	68 bf 39 10 f0       	push   $0xf01039bf
f0100952:	e8 89 1d 00 00       	call   f01026e0 <cprintf>
f0100957:	83 c4 10             	add    $0x10,%esp
f010095a:	e9 f6 fe ff ff       	jmp    f0100855 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010095f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100962:	5b                   	pop    %ebx
f0100963:	5e                   	pop    %esi
f0100964:	5f                   	pop    %edi
f0100965:	5d                   	pop    %ebp
f0100966:	c3                   	ret    

f0100967 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100967:	55                   	push   %ebp
f0100968:	89 e5                	mov    %esp,%ebp
f010096a:	56                   	push   %esi
f010096b:	53                   	push   %ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010096c:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f0100973:	75 11                	jne    f0100986 <boot_alloc+0x1f>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100975:	ba 6f 89 11 f0       	mov    $0xf011896f,%edx
f010097a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100980:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100986:	8b 1d 38 75 11 f0    	mov    0xf0117538,%ebx
	nextfree = ROUNDUP(result+n, PGSIZE);
f010098c:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f0100993:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100999:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	
	if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE) {
f010099f:	8d b2 00 00 00 10    	lea    0x10000000(%edx),%esi
f01009a5:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f01009ab:	c1 e1 0c             	shl    $0xc,%ecx
f01009ae:	39 ce                	cmp    %ecx,%esi
f01009b0:	76 17                	jbe    f01009c9 <boot_alloc+0x62>
		panic("file: pmap.c\nfunction: boot_alloc\nMore memory allocated than possible\nresult -> %p\nn -> %d\nnextfree -> %p", result, n, nextfree);
f01009b2:	83 ec 08             	sub    $0x8,%esp
f01009b5:	52                   	push   %edx
f01009b6:	50                   	push   %eax
f01009b7:	53                   	push   %ebx
f01009b8:	68 a4 3b 10 f0       	push   $0xf0103ba4
f01009bd:	6a 69                	push   $0x69
f01009bf:	68 20 44 10 f0       	push   $0xf0104420
f01009c4:	e8 0b f7 ff ff       	call   f01000d4 <_panic>
	}
	return result;
}
f01009c9:	89 d8                	mov    %ebx,%eax
f01009cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009ce:	5b                   	pop    %ebx
f01009cf:	5e                   	pop    %esi
f01009d0:	5d                   	pop    %ebp
f01009d1:	c3                   	ret    

f01009d2 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009d2:	89 d1                	mov    %edx,%ecx
f01009d4:	c1 e9 16             	shr    $0x16,%ecx
f01009d7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009da:	a8 01                	test   $0x1,%al
f01009dc:	74 52                	je     f0100a30 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009e3:	89 c1                	mov    %eax,%ecx
f01009e5:	c1 e9 0c             	shr    $0xc,%ecx
f01009e8:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f01009ee:	72 1b                	jb     f0100a0b <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009f0:	55                   	push   %ebp
f01009f1:	89 e5                	mov    %esp,%ebp
f01009f3:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009f6:	50                   	push   %eax
f01009f7:	68 10 3c 10 f0       	push   $0xf0103c10
f01009fc:	68 d6 02 00 00       	push   $0x2d6
f0100a01:	68 20 44 10 f0       	push   $0xf0104420
f0100a06:	e8 c9 f6 ff ff       	call   f01000d4 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a0b:	c1 ea 0c             	shr    $0xc,%edx
f0100a0e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a14:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a1b:	89 c2                	mov    %eax,%edx
f0100a1d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a25:	85 d2                	test   %edx,%edx
f0100a27:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a2c:	0f 44 c2             	cmove  %edx,%eax
f0100a2f:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a35:	c3                   	ret    

f0100a36 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a36:	55                   	push   %ebp
f0100a37:	89 e5                	mov    %esp,%ebp
f0100a39:	57                   	push   %edi
f0100a3a:	56                   	push   %esi
f0100a3b:	53                   	push   %ebx
f0100a3c:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a3f:	84 c0                	test   %al,%al
f0100a41:	0f 85 bc 02 00 00    	jne    f0100d03 <check_page_free_list+0x2cd>
f0100a47:	e9 df 02 00 00       	jmp    f0100d2b <check_page_free_list+0x2f5>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a4c:	83 ec 04             	sub    $0x4,%esp
f0100a4f:	68 34 3c 10 f0       	push   $0xf0103c34
f0100a54:	68 17 02 00 00       	push   $0x217
f0100a59:	68 20 44 10 f0       	push   $0xf0104420
f0100a5e:	e8 71 f6 ff ff       	call   f01000d4 <_panic>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a63:	89 c2                	mov    %eax,%edx
f0100a65:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0100a6b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a71:	0f 95 c2             	setne  %dl
f0100a74:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a77:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a7b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a7d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a81:	8b 00                	mov    (%eax),%eax
f0100a83:	85 c0                	test   %eax,%eax
f0100a85:	75 dc                	jne    f0100a63 <check_page_free_list+0x2d>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a93:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a96:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a98:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a9b:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aa0:	be 01 00 00 00       	mov    $0x1,%esi
		*tp[1] = 0;
		*tp[0] = pp2;
		page_free_list = pp1;
	}

	cprintf("here2 \n");
f0100aa5:	83 ec 0c             	sub    $0xc,%esp
f0100aa8:	68 2c 44 10 f0       	push   $0xf010442c
f0100aad:	e8 2e 1c 00 00       	call   f01026e0 <cprintf>
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ab2:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100ab8:	83 c4 10             	add    $0x10,%esp
f0100abb:	eb 53                	jmp    f0100b10 <check_page_free_list+0xda>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100abd:	89 d8                	mov    %ebx,%eax
f0100abf:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100ac5:	c1 f8 03             	sar    $0x3,%eax
f0100ac8:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100acb:	89 c2                	mov    %eax,%edx
f0100acd:	c1 ea 16             	shr    $0x16,%edx
f0100ad0:	39 f2                	cmp    %esi,%edx
f0100ad2:	73 3a                	jae    f0100b0e <check_page_free_list+0xd8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ad4:	89 c2                	mov    %eax,%edx
f0100ad6:	c1 ea 0c             	shr    $0xc,%edx
f0100ad9:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100adf:	72 12                	jb     f0100af3 <check_page_free_list+0xbd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ae1:	50                   	push   %eax
f0100ae2:	68 10 3c 10 f0       	push   $0xf0103c10
f0100ae7:	6a 52                	push   $0x52
f0100ae9:	68 34 44 10 f0       	push   $0xf0104434
f0100aee:	e8 e1 f5 ff ff       	call   f01000d4 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af3:	83 ec 04             	sub    $0x4,%esp
f0100af6:	68 80 00 00 00       	push   $0x80
f0100afb:	68 97 00 00 00       	push   $0x97
f0100b00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b05:	50                   	push   %eax
f0100b06:	e8 8e 26 00 00       	call   f0103199 <memset>
f0100b0b:	83 c4 10             	add    $0x10,%esp
	}

	cprintf("here2 \n");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b0e:	8b 1b                	mov    (%ebx),%ebx
f0100b10:	85 db                	test   %ebx,%ebx
f0100b12:	75 a9                	jne    f0100abd <check_page_free_list+0x87>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	cprintf("here3 \n");
f0100b14:	83 ec 0c             	sub    $0xc,%esp
f0100b17:	68 42 44 10 f0       	push   $0xf0104442
f0100b1c:	e8 bf 1b 00 00       	call   f01026e0 <cprintf>
	first_free_page = (char *) boot_alloc(0);
f0100b21:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b26:	e8 3c fe ff ff       	call   f0100967 <boot_alloc>
f0100b2b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b2e:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b34:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100b3a:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0100b3f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b42:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b45:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	cprintf("here3 \n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b48:	83 c4 10             	add    $0x10,%esp
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b4b:	be 00 00 00 00       	mov    $0x0,%esi
f0100b50:	89 5d d0             	mov    %ebx,-0x30(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	cprintf("here3 \n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b53:	e9 30 01 00 00       	jmp    f0100c88 <check_page_free_list+0x252>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b58:	39 ca                	cmp    %ecx,%edx
f0100b5a:	73 19                	jae    f0100b75 <check_page_free_list+0x13f>
f0100b5c:	68 4a 44 10 f0       	push   $0xf010444a
f0100b61:	68 56 44 10 f0       	push   $0xf0104456
f0100b66:	68 33 02 00 00       	push   $0x233
f0100b6b:	68 20 44 10 f0       	push   $0xf0104420
f0100b70:	e8 5f f5 ff ff       	call   f01000d4 <_panic>
		assert(pp < pages + npages);
f0100b75:	39 fa                	cmp    %edi,%edx
f0100b77:	72 19                	jb     f0100b92 <check_page_free_list+0x15c>
f0100b79:	68 6b 44 10 f0       	push   $0xf010446b
f0100b7e:	68 56 44 10 f0       	push   $0xf0104456
f0100b83:	68 34 02 00 00       	push   $0x234
f0100b88:	68 20 44 10 f0       	push   $0xf0104420
f0100b8d:	e8 42 f5 ff ff       	call   f01000d4 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b92:	89 d0                	mov    %edx,%eax
f0100b94:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b97:	a8 07                	test   $0x7,%al
f0100b99:	74 19                	je     f0100bb4 <check_page_free_list+0x17e>
f0100b9b:	68 58 3c 10 f0       	push   $0xf0103c58
f0100ba0:	68 56 44 10 f0       	push   $0xf0104456
f0100ba5:	68 35 02 00 00       	push   $0x235
f0100baa:	68 20 44 10 f0       	push   $0xf0104420
f0100baf:	e8 20 f5 ff ff       	call   f01000d4 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bb4:	c1 f8 03             	sar    $0x3,%eax
f0100bb7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bba:	85 c0                	test   %eax,%eax
f0100bbc:	75 19                	jne    f0100bd7 <check_page_free_list+0x1a1>
f0100bbe:	68 7f 44 10 f0       	push   $0xf010447f
f0100bc3:	68 56 44 10 f0       	push   $0xf0104456
f0100bc8:	68 38 02 00 00       	push   $0x238
f0100bcd:	68 20 44 10 f0       	push   $0xf0104420
f0100bd2:	e8 fd f4 ff ff       	call   f01000d4 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bd7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bdc:	75 19                	jne    f0100bf7 <check_page_free_list+0x1c1>
f0100bde:	68 90 44 10 f0       	push   $0xf0104490
f0100be3:	68 56 44 10 f0       	push   $0xf0104456
f0100be8:	68 39 02 00 00       	push   $0x239
f0100bed:	68 20 44 10 f0       	push   $0xf0104420
f0100bf2:	e8 dd f4 ff ff       	call   f01000d4 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bf7:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bfc:	75 19                	jne    f0100c17 <check_page_free_list+0x1e1>
f0100bfe:	68 8c 3c 10 f0       	push   $0xf0103c8c
f0100c03:	68 56 44 10 f0       	push   $0xf0104456
f0100c08:	68 3a 02 00 00       	push   $0x23a
f0100c0d:	68 20 44 10 f0       	push   $0xf0104420
f0100c12:	e8 bd f4 ff ff       	call   f01000d4 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c17:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c1c:	75 19                	jne    f0100c37 <check_page_free_list+0x201>
f0100c1e:	68 a9 44 10 f0       	push   $0xf01044a9
f0100c23:	68 56 44 10 f0       	push   $0xf0104456
f0100c28:	68 3b 02 00 00       	push   $0x23b
f0100c2d:	68 20 44 10 f0       	push   $0xf0104420
f0100c32:	e8 9d f4 ff ff       	call   f01000d4 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c37:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c3c:	76 3f                	jbe    f0100c7d <check_page_free_list+0x247>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c3e:	89 c3                	mov    %eax,%ebx
f0100c40:	c1 eb 0c             	shr    $0xc,%ebx
f0100c43:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c46:	77 12                	ja     f0100c5a <check_page_free_list+0x224>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c48:	50                   	push   %eax
f0100c49:	68 10 3c 10 f0       	push   $0xf0103c10
f0100c4e:	6a 52                	push   $0x52
f0100c50:	68 34 44 10 f0       	push   $0xf0104434
f0100c55:	e8 7a f4 ff ff       	call   f01000d4 <_panic>
f0100c5a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c5f:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c62:	76 1e                	jbe    f0100c82 <check_page_free_list+0x24c>
f0100c64:	68 b0 3c 10 f0       	push   $0xf0103cb0
f0100c69:	68 56 44 10 f0       	push   $0xf0104456
f0100c6e:	68 3c 02 00 00       	push   $0x23c
f0100c73:	68 20 44 10 f0       	push   $0xf0104420
f0100c78:	e8 57 f4 ff ff       	call   f01000d4 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c7d:	83 c6 01             	add    $0x1,%esi
f0100c80:	eb 04                	jmp    f0100c86 <check_page_free_list+0x250>
		else
			++nfree_extmem;
f0100c82:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	cprintf("here3 \n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c86:	8b 12                	mov    (%edx),%edx
f0100c88:	85 d2                	test   %edx,%edx
f0100c8a:	0f 85 c8 fe ff ff    	jne    f0100b58 <check_page_free_list+0x122>
f0100c90:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
		else
			++nfree_extmem;
	}
	cprintf("here4 \n");
f0100c93:	83 ec 0c             	sub    $0xc,%esp
f0100c96:	68 c3 44 10 f0       	push   $0xf01044c3
f0100c9b:	e8 40 1a 00 00       	call   f01026e0 <cprintf>
	assert(nfree_basemem > 0);
f0100ca0:	83 c4 10             	add    $0x10,%esp
f0100ca3:	85 f6                	test   %esi,%esi
f0100ca5:	7f 19                	jg     f0100cc0 <check_page_free_list+0x28a>
f0100ca7:	68 cb 44 10 f0       	push   $0xf01044cb
f0100cac:	68 56 44 10 f0       	push   $0xf0104456
f0100cb1:	68 44 02 00 00       	push   $0x244
f0100cb6:	68 20 44 10 f0       	push   $0xf0104420
f0100cbb:	e8 14 f4 ff ff       	call   f01000d4 <_panic>
	assert(nfree_extmem > 0);
f0100cc0:	85 db                	test   %ebx,%ebx
f0100cc2:	7f 75                	jg     f0100d39 <check_page_free_list+0x303>
f0100cc4:	68 dd 44 10 f0       	push   $0xf01044dd
f0100cc9:	68 56 44 10 f0       	push   $0xf0104456
f0100cce:	68 45 02 00 00       	push   $0x245
f0100cd3:	68 20 44 10 f0       	push   $0xf0104420
f0100cd8:	e8 f7 f3 ff ff       	call   f01000d4 <_panic>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
	cprintf("here1 \n");
f0100cdd:	83 ec 0c             	sub    $0xc,%esp
f0100ce0:	68 ee 44 10 f0       	push   $0xf01044ee
f0100ce5:	e8 f6 19 00 00       	call   f01026e0 <cprintf>
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100cea:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0100ced:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100cf0:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0100cf3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cf6:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100cfb:	83 c4 10             	add    $0x10,%esp
f0100cfe:	e9 80 fd ff ff       	jmp    f0100a83 <check_page_free_list+0x4d>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d03:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100d0a:	75 d1                	jne    f0100cdd <check_page_free_list+0x2a7>
f0100d0c:	e9 3b fd ff ff       	jmp    f0100a4c <check_page_free_list+0x16>
		panic("'page_free_list' is a null pointer!");
	cprintf("here1 \n");
f0100d11:	83 ec 0c             	sub    $0xc,%esp
f0100d14:	68 ee 44 10 f0       	push   $0xf01044ee
f0100d19:	e8 c2 19 00 00       	call   f01026e0 <cprintf>
f0100d1e:	83 c4 10             	add    $0x10,%esp
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d21:	be 00 04 00 00       	mov    $0x400,%esi
f0100d26:	e9 7a fd ff ff       	jmp    f0100aa5 <check_page_free_list+0x6f>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d2b:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100d32:	75 dd                	jne    f0100d11 <check_page_free_list+0x2db>
f0100d34:	e9 13 fd ff ff       	jmp    f0100a4c <check_page_free_list+0x16>
			++nfree_extmem;
	}
	cprintf("here4 \n");
	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d3c:	5b                   	pop    %ebx
f0100d3d:	5e                   	pop    %esi
f0100d3e:	5f                   	pop    %edi
f0100d3f:	5d                   	pop    %ebp
f0100d40:	c3                   	ret    

f0100d41 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d41:	55                   	push   %ebp
f0100d42:	89 e5                	mov    %esp,%ebp
f0100d44:	57                   	push   %edi
f0100d45:	56                   	push   %esi
f0100d46:	53                   	push   %ebx
f0100d47:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
f0100d4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d4f:	e8 13 fc ff ff       	call   f0100967 <boot_alloc>
f0100d54:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d59:	c1 e8 0c             	shr    $0xc,%eax
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
		if (0 == i || ((i >= npages_basemem) && (i < (npages_basemem + num_of_io_pages))) \
f0100d5c:	8b 0d 40 75 11 f0    	mov    0xf0117540,%ecx
f0100d62:	8d 59 60             	lea    0x60(%ecx),%ebx
f0100d65:	8b 35 3c 75 11 f0    	mov    0xf011753c,%esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
f0100d6b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d70:	ba 00 00 00 00       	mov    $0x0,%edx
		if (0 == i || ((i >= npages_basemem) && (i < (npages_basemem + num_of_io_pages))) \
            || ((i >= npages_basemem + num_of_io_pages) && \
f0100d75:	01 d8                	add    %ebx,%eax
f0100d77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
f0100d7a:	eb 4c                	jmp    f0100dc8 <page_init+0x87>
		if (0 == i || ((i >= npages_basemem) && (i < (npages_basemem + num_of_io_pages))) \
f0100d7c:	85 d2                	test   %edx,%edx
f0100d7e:	74 13                	je     f0100d93 <page_init+0x52>
f0100d80:	39 ca                	cmp    %ecx,%edx
f0100d82:	72 06                	jb     f0100d8a <page_init+0x49>
f0100d84:	39 da                	cmp    %ebx,%edx
f0100d86:	72 0b                	jb     f0100d93 <page_init+0x52>
f0100d88:	eb 04                	jmp    f0100d8e <page_init+0x4d>
            || ((i >= npages_basemem + num_of_io_pages) && \
f0100d8a:	39 da                	cmp    %ebx,%edx
f0100d8c:	72 13                	jb     f0100da1 <page_init+0x60>
f0100d8e:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100d91:	73 0e                	jae    f0100da1 <page_init+0x60>
            ( i < (npages_basemem + num_of_io_pages+num_of_kern_pages_plus_pgdir)))) {
			pages[i].pp_ref = 1;
f0100d93:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0100d98:	66 c7 44 d0 04 01 00 	movw   $0x1,0x4(%eax,%edx,8)
			continue;
f0100d9f:	eb 24                	jmp    f0100dc5 <page_init+0x84>
f0100da1:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
		}
		pages[i].pp_ref = 0;
f0100da8:	89 c7                	mov    %eax,%edi
f0100daa:	03 3d 6c 79 11 f0    	add    0xf011796c,%edi
f0100db0:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f0100db6:	89 37                	mov    %esi,(%edi)
		page_free_list = &pages[i];
f0100db8:	03 05 6c 79 11 f0    	add    0xf011796c,%eax
f0100dbe:	89 c6                	mov    %eax,%esi
f0100dc0:	bf 01 00 00 00       	mov    $0x1,%edi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t num_of_kern_pages_plus_pgdir = ((uint32_t) boot_alloc(0) - KERNBASE)/ PGSIZE;
	uint32_t num_of_io_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for (i = 0; i < npages; i++) {
f0100dc5:	83 c2 01             	add    $0x1,%edx
f0100dc8:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100dce:	72 ac                	jb     f0100d7c <page_init+0x3b>
f0100dd0:	89 f8                	mov    %edi,%eax
f0100dd2:	84 c0                	test   %al,%al
f0100dd4:	74 06                	je     f0100ddc <page_init+0x9b>
f0100dd6:	89 35 3c 75 11 f0    	mov    %esi,0xf011753c
		}
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100ddc:	83 c4 1c             	add    $0x1c,%esp
f0100ddf:	5b                   	pop    %ebx
f0100de0:	5e                   	pop    %esi
f0100de1:	5f                   	pop    %edi
f0100de2:	5d                   	pop    %ebp
f0100de3:	c3                   	ret    

f0100de4 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100de4:	55                   	push   %ebp
f0100de5:	89 e5                	mov    %esp,%ebp
f0100de7:	53                   	push   %ebx
f0100de8:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if (page_free_list == NULL){
f0100deb:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100df1:	85 db                	test   %ebx,%ebx
f0100df3:	74 78                	je     f0100e6d <page_alloc+0x89>
		return NULL;
	}
	struct PageInfo * temp;
	temp = page_free_list;
	assert(temp->pp_ref == 0);
f0100df5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100dfa:	74 19                	je     f0100e15 <page_alloc+0x31>
f0100dfc:	68 f6 44 10 f0       	push   $0xf01044f6
f0100e01:	68 56 44 10 f0       	push   $0xf0104456
f0100e06:	68 28 01 00 00       	push   $0x128
f0100e0b:	68 20 44 10 f0       	push   $0xf0104420
f0100e10:	e8 bf f2 ff ff       	call   f01000d4 <_panic>
	page_free_list = page_free_list->pp_link;
f0100e15:	8b 03                	mov    (%ebx),%eax
f0100e17:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	temp->pp_link = NULL;
f0100e1c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO){
f0100e22:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e26:	74 45                	je     f0100e6d <page_alloc+0x89>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e28:	89 d8                	mov    %ebx,%eax
f0100e2a:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100e30:	c1 f8 03             	sar    $0x3,%eax
f0100e33:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e36:	89 c2                	mov    %eax,%edx
f0100e38:	c1 ea 0c             	shr    $0xc,%edx
f0100e3b:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100e41:	72 12                	jb     f0100e55 <page_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e43:	50                   	push   %eax
f0100e44:	68 10 3c 10 f0       	push   $0xf0103c10
f0100e49:	6a 52                	push   $0x52
f0100e4b:	68 34 44 10 f0       	push   $0xf0104434
f0100e50:	e8 7f f2 ff ff       	call   f01000d4 <_panic>
		memset(page2kva(temp), 0, PGSIZE);
f0100e55:	83 ec 04             	sub    $0x4,%esp
f0100e58:	68 00 10 00 00       	push   $0x1000
f0100e5d:	6a 00                	push   $0x0
f0100e5f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e64:	50                   	push   %eax
f0100e65:	e8 2f 23 00 00       	call   f0103199 <memset>
f0100e6a:	83 c4 10             	add    $0x10,%esp
	}
	return temp;

}
f0100e6d:	89 d8                	mov    %ebx,%eax
f0100e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e72:	c9                   	leave  
f0100e73:	c3                   	ret    

f0100e74 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e74:	55                   	push   %ebp
f0100e75:	89 e5                	mov    %esp,%ebp
f0100e77:	83 ec 08             	sub    $0x8,%esp
f0100e7a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	assert(pp->pp_ref == 0);
f0100e7d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e82:	74 19                	je     f0100e9d <page_free+0x29>
f0100e84:	68 08 45 10 f0       	push   $0xf0104508
f0100e89:	68 56 44 10 f0       	push   $0xf0104456
f0100e8e:	68 3a 01 00 00       	push   $0x13a
f0100e93:	68 20 44 10 f0       	push   $0xf0104420
f0100e98:	e8 37 f2 ff ff       	call   f01000d4 <_panic>
	pp->pp_link = page_free_list;
f0100e9d:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100ea3:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ea5:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	return;
}
f0100eaa:	c9                   	leave  
f0100eab:	c3                   	ret    

f0100eac <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100eac:	55                   	push   %ebp
f0100ead:	89 e5                	mov    %esp,%ebp
f0100eaf:	83 ec 08             	sub    $0x8,%esp
f0100eb2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100eb5:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100eb9:	83 e8 01             	sub    $0x1,%eax
f0100ebc:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100ec0:	66 85 c0             	test   %ax,%ax
f0100ec3:	75 0c                	jne    f0100ed1 <page_decref+0x25>
		page_free(pp);
f0100ec5:	83 ec 0c             	sub    $0xc,%esp
f0100ec8:	52                   	push   %edx
f0100ec9:	e8 a6 ff ff ff       	call   f0100e74 <page_free>
f0100ece:	83 c4 10             	add    $0x10,%esp
}
f0100ed1:	c9                   	leave  
f0100ed2:	c3                   	ret    

f0100ed3 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ed3:	55                   	push   %ebp
f0100ed4:	89 e5                	mov    %esp,%ebp
f0100ed6:	56                   	push   %esi
f0100ed7:	53                   	push   %ebx
f0100ed8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100edb:	8b 55 10             	mov    0x10(%ebp),%edx
	// Fill this function in
	pde_t * pde;
	struct PageInfo * newPage;
	pde = &pgdir[PDX(va)];
f0100ede:	89 f3                	mov    %esi,%ebx
f0100ee0:	c1 eb 16             	shr    $0x16,%ebx
f0100ee3:	c1 e3 02             	shl    $0x2,%ebx
f0100ee6:	03 5d 08             	add    0x8(%ebp),%ebx

	if (!(*pde & PTE_P) && !create){
f0100ee9:	8b 03                	mov    (%ebx),%eax
f0100eeb:	83 f0 01             	xor    $0x1,%eax
f0100eee:	83 e0 01             	and    $0x1,%eax
f0100ef1:	85 d2                	test   %edx,%edx
f0100ef3:	75 04                	jne    f0100ef9 <pgdir_walk+0x26>
f0100ef5:	84 c0                	test   %al,%al
f0100ef7:	75 6a                	jne    f0100f63 <pgdir_walk+0x90>
		return NULL;
	}
	if ( !(*pde & PTE_P) && create){
f0100ef9:	85 d2                	test   %edx,%edx
f0100efb:	74 2b                	je     f0100f28 <pgdir_walk+0x55>
f0100efd:	84 c0                	test   %al,%al
f0100eff:	74 27                	je     f0100f28 <pgdir_walk+0x55>
		newPage = (struct PageInfo *) page_alloc(1);
f0100f01:	83 ec 0c             	sub    $0xc,%esp
f0100f04:	6a 01                	push   $0x1
f0100f06:	e8 d9 fe ff ff       	call   f0100de4 <page_alloc>
		if (newPage == NULL){	
f0100f0b:	83 c4 10             	add    $0x10,%esp
f0100f0e:	85 c0                	test   %eax,%eax
f0100f10:	74 58                	je     f0100f6a <pgdir_walk+0x97>
			return NULL;
		}
		newPage->pp_ref += 1;
f0100f12:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		*pde = (page2pa(newPage) | PTE_P | PTE_W | PTE_U );
f0100f17:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100f1d:	c1 f8 03             	sar    $0x3,%eax
f0100f20:	c1 e0 0c             	shl    $0xc,%eax
f0100f23:	83 c8 07             	or     $0x7,%eax
f0100f26:	89 03                	mov    %eax,(%ebx)
		
	}
	pte_t * temp = KADDR(PTE_ADDR(*pde));
f0100f28:	8b 03                	mov    (%ebx),%eax
f0100f2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f2f:	89 c2                	mov    %eax,%edx
f0100f31:	c1 ea 0c             	shr    $0xc,%edx
f0100f34:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100f3a:	72 15                	jb     f0100f51 <pgdir_walk+0x7e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f3c:	50                   	push   %eax
f0100f3d:	68 10 3c 10 f0       	push   $0xf0103c10
f0100f42:	68 75 01 00 00       	push   $0x175
f0100f47:	68 20 44 10 f0       	push   $0xf0104420
f0100f4c:	e8 83 f1 ff ff       	call   f01000d4 <_panic>
	return &temp[PTX(va)];
f0100f51:	c1 ee 0a             	shr    $0xa,%esi
f0100f54:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100f5a:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100f61:	eb 0c                	jmp    f0100f6f <pgdir_walk+0x9c>
	pde_t * pde;
	struct PageInfo * newPage;
	pde = &pgdir[PDX(va)];

	if (!(*pde & PTE_P) && !create){
		return NULL;
f0100f63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f68:	eb 05                	jmp    f0100f6f <pgdir_walk+0x9c>
	}
	if ( !(*pde & PTE_P) && create){
		newPage = (struct PageInfo *) page_alloc(1);
		if (newPage == NULL){	
			return NULL;
f0100f6a:	b8 00 00 00 00       	mov    $0x0,%eax
		*pde = (page2pa(newPage) | PTE_P | PTE_W | PTE_U );
		
	}
	pte_t * temp = KADDR(PTE_ADDR(*pde));
	return &temp[PTX(va)];
}
f0100f6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f72:	5b                   	pop    %ebx
f0100f73:	5e                   	pop    %esi
f0100f74:	5d                   	pop    %ebp
f0100f75:	c3                   	ret    

f0100f76 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f76:	55                   	push   %ebp
f0100f77:	89 e5                	mov    %esp,%ebp
f0100f79:	53                   	push   %ebx
f0100f7a:	83 ec 08             	sub    $0x8,%esp
f0100f7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t * temp = pgdir_walk(pgdir, va, false);
f0100f80:	6a 00                	push   $0x0
f0100f82:	ff 75 0c             	pushl  0xc(%ebp)
f0100f85:	ff 75 08             	pushl  0x8(%ebp)
f0100f88:	e8 46 ff ff ff       	call   f0100ed3 <pgdir_walk>
	if (temp == NULL){
		return NULL;
	}
	if (pte_store == NULL) {
f0100f8d:	83 c4 10             	add    $0x10,%esp
f0100f90:	85 c0                	test   %eax,%eax
f0100f92:	74 32                	je     f0100fc6 <page_lookup+0x50>
f0100f94:	85 db                	test   %ebx,%ebx
f0100f96:	74 2e                	je     f0100fc6 <page_lookup+0x50>
		return NULL;
	}
	*pte_store = temp;
f0100f98:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f9a:	8b 00                	mov    (%eax),%eax
f0100f9c:	c1 e8 0c             	shr    $0xc,%eax
f0100f9f:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0100fa5:	72 14                	jb     f0100fbb <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0100fa7:	83 ec 04             	sub    $0x4,%esp
f0100faa:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100faf:	6a 4b                	push   $0x4b
f0100fb1:	68 34 44 10 f0       	push   $0xf0104434
f0100fb6:	e8 19 f1 ff ff       	call   f01000d4 <_panic>
	return &pages[PGNUM(pa)];
f0100fbb:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0100fc1:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	physaddr_t pp = PTE_ADDR(*temp);
	return pa2page(pp);
f0100fc4:	eb 05                	jmp    f0100fcb <page_lookup+0x55>
	pte_t * temp = pgdir_walk(pgdir, va, false);
	if (temp == NULL){
		return NULL;
	}
	if (pte_store == NULL) {
		return NULL;
f0100fc6:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	*pte_store = temp;
	physaddr_t pp = PTE_ADDR(*temp);
	return pa2page(pp);
}
f0100fcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fce:	c9                   	leave  
f0100fcf:	c3                   	ret    

f0100fd0 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100fd0:	55                   	push   %ebp
f0100fd1:	89 e5                	mov    %esp,%ebp
f0100fd3:	53                   	push   %ebx
f0100fd4:	83 ec 18             	sub    $0x18,%esp
f0100fd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * temp;
	struct PageInfo * pg_tmp = page_lookup(pgdir,va, &temp);
f0100fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fdd:	50                   	push   %eax
f0100fde:	53                   	push   %ebx
f0100fdf:	ff 75 08             	pushl  0x8(%ebp)
f0100fe2:	e8 8f ff ff ff       	call   f0100f76 <page_lookup>
	if (pg_tmp == NULL){
f0100fe7:	83 c4 10             	add    $0x10,%esp
f0100fea:	85 c0                	test   %eax,%eax
f0100fec:	74 18                	je     f0101006 <page_remove+0x36>
		return;
	}
	page_decref(pg_tmp);
f0100fee:	83 ec 0c             	sub    $0xc,%esp
f0100ff1:	50                   	push   %eax
f0100ff2:	e8 b5 fe ff ff       	call   f0100eac <page_decref>
	//pte_t * temp2 = &pgdir[PDX[va]];
	//pte_t * temp3 = KADDR(PTE_ADDR(*temp2));
	//temp3[PTX[va]] = NULL;
	*temp = (*temp & 0);
f0100ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ffa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101000:	0f 01 3b             	invlpg (%ebx)
f0101003:	83 c4 10             	add    $0x10,%esp
	tlb_invalidate(pgdir,va);
	return;
}
f0101006:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101009:	c9                   	leave  
f010100a:	c3                   	ret    

f010100b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010100b:	55                   	push   %ebp
f010100c:	89 e5                	mov    %esp,%ebp
f010100e:	57                   	push   %edi
f010100f:	56                   	push   %esi
f0101010:	53                   	push   %ebx
f0101011:	83 ec 10             	sub    $0x10,%esp
f0101014:	8b 75 08             	mov    0x8(%ebp),%esi
f0101017:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * temp;
	if ((temp = (pte_t *)pgdir_walk(pgdir,va, true)) == NULL){
f010101a:	6a 01                	push   $0x1
f010101c:	ff 75 10             	pushl  0x10(%ebp)
f010101f:	56                   	push   %esi
f0101020:	e8 ae fe ff ff       	call   f0100ed3 <pgdir_walk>
f0101025:	89 c7                	mov    %eax,%edi
f0101027:	83 c4 10             	add    $0x10,%esp
		return E_NO_MEM;
f010102a:	b8 04 00 00 00       	mov    $0x4,%eax
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t * temp;
	if ((temp = (pte_t *)pgdir_walk(pgdir,va, true)) == NULL){
f010102f:	85 ff                	test   %edi,%edi
f0101031:	74 3d                	je     f0101070 <page_insert+0x65>
		return E_NO_MEM;
	}
	if (*temp & PTE_P){
f0101033:	f6 07 01             	testb  $0x1,(%edi)
f0101036:	74 0f                	je     f0101047 <page_insert+0x3c>
		page_remove(pgdir,va);
f0101038:	83 ec 08             	sub    $0x8,%esp
f010103b:	ff 75 10             	pushl  0x10(%ebp)
f010103e:	56                   	push   %esi
f010103f:	e8 8c ff ff ff       	call   f0100fd0 <page_remove>
f0101044:	83 c4 10             	add    $0x10,%esp
	}
	pp->pp_ref += 1;
f0101047:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
f010104c:	8b 45 14             	mov    0x14(%ebp),%eax
f010104f:	83 c8 01             	or     $0x1,%eax
	*temp = (page2pa(pp) | perm | PTE_P);
f0101052:	2b 1d 6c 79 11 f0    	sub    0xf011796c,%ebx
f0101058:	c1 fb 03             	sar    $0x3,%ebx
f010105b:	c1 e3 0c             	shl    $0xc,%ebx
f010105e:	09 c3                	or     %eax,%ebx
f0101060:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f0101062:	8b 55 10             	mov    0x10(%ebp),%edx
f0101065:	c1 ea 16             	shr    $0x16,%edx
	pgdir[PDX(va)] |= PTE_P;
f0101068:	09 04 96             	or     %eax,(%esi,%edx,4)
	return 0;
f010106b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101070:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101073:	5b                   	pop    %ebx
f0101074:	5e                   	pop    %esi
f0101075:	5f                   	pop    %edi
f0101076:	5d                   	pop    %ebp
f0101077:	c3                   	ret    

f0101078 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101078:	55                   	push   %ebp
f0101079:	89 e5                	mov    %esp,%ebp
f010107b:	57                   	push   %edi
f010107c:	56                   	push   %esi
f010107d:	53                   	push   %ebx
f010107e:	83 ec 38             	sub    $0x38,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	cprintf("Entering i386_detect_memory function.\n");
f0101081:	68 18 3d 10 f0       	push   $0xf0103d18
f0101086:	e8 55 16 00 00       	call   f01026e0 <cprintf>
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010108b:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101092:	e8 e2 15 00 00       	call   f0102679 <mc146818_read>
f0101097:	89 c3                	mov    %eax,%ebx
f0101099:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01010a0:	e8 d4 15 00 00       	call   f0102679 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01010a5:	c1 e0 08             	shl    $0x8,%eax
f01010a8:	09 d8                	or     %ebx,%eax
f01010aa:	c1 e0 0a             	shl    $0xa,%eax
f01010ad:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010b3:	85 c0                	test   %eax,%eax
f01010b5:	0f 48 c2             	cmovs  %edx,%eax
f01010b8:	c1 f8 0c             	sar    $0xc,%eax
f01010bb:	a3 40 75 11 f0       	mov    %eax,0xf0117540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010c0:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01010c7:	e8 ad 15 00 00       	call   f0102679 <mc146818_read>
f01010cc:	89 c3                	mov    %eax,%ebx
f01010ce:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01010d5:	e8 9f 15 00 00       	call   f0102679 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01010da:	c1 e0 08             	shl    $0x8,%eax
f01010dd:	09 d8                	or     %ebx,%eax
f01010df:	c1 e0 0a             	shl    $0xa,%eax
f01010e2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010e8:	83 c4 10             	add    $0x10,%esp
f01010eb:	85 c0                	test   %eax,%eax
f01010ed:	0f 48 c2             	cmovs  %edx,%eax
f01010f0:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01010f3:	85 c0                	test   %eax,%eax
f01010f5:	74 0e                	je     f0101105 <mem_init+0x8d>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01010f7:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01010fd:	89 15 64 79 11 f0    	mov    %edx,0xf0117964
f0101103:	eb 0c                	jmp    f0101111 <mem_init+0x99>
	else
		npages = npages_basemem;
f0101105:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f010110b:	89 15 64 79 11 f0    	mov    %edx,0xf0117964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101111:	c1 e0 0c             	shl    $0xc,%eax
f0101114:	c1 e8 0a             	shr    $0xa,%eax
f0101117:	50                   	push   %eax
f0101118:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f010111d:	c1 e0 0c             	shl    $0xc,%eax
f0101120:	c1 e8 0a             	shr    $0xa,%eax
f0101123:	50                   	push   %eax
f0101124:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101129:	c1 e0 0c             	shl    $0xc,%eax
f010112c:	c1 e8 0a             	shr    $0xa,%eax
f010112f:	50                   	push   %eax
f0101130:	68 40 3d 10 f0       	push   $0xf0103d40
f0101135:	e8 a6 15 00 00       	call   f01026e0 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	cprintf("Entering boot_alloc for the kern_pgdir.\n");
f010113a:	c7 04 24 7c 3d 10 f0 	movl   $0xf0103d7c,(%esp)
f0101141:	e8 9a 15 00 00       	call   f01026e0 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101146:	b8 00 10 00 00       	mov    $0x1000,%eax
f010114b:	e8 17 f8 ff ff       	call   f0100967 <boot_alloc>
f0101150:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	memset(kern_pgdir, 0, PGSIZE);
f0101155:	83 c4 0c             	add    $0xc,%esp
f0101158:	68 00 10 00 00       	push   $0x1000
f010115d:	6a 00                	push   $0x0
f010115f:	50                   	push   %eax
f0101160:	e8 34 20 00 00       	call   f0103199 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101165:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010116a:	83 c4 10             	add    $0x10,%esp
f010116d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101172:	77 15                	ja     f0101189 <mem_init+0x111>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101174:	50                   	push   %eax
f0101175:	68 a8 3d 10 f0       	push   $0xf0103da8
f010117a:	68 91 00 00 00       	push   $0x91
f010117f:	68 20 44 10 f0       	push   $0xf0104420
f0101184:	e8 4b ef ff ff       	call   f01000d4 <_panic>
f0101189:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010118f:	83 ca 05             	or     $0x5,%edx
f0101192:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	cprintf("Entering boot_alloc for the pages array.\n");
f0101198:	83 ec 0c             	sub    $0xc,%esp
f010119b:	68 cc 3d 10 f0       	push   $0xf0103dcc
f01011a0:	e8 3b 15 00 00       	call   f01026e0 <cprintf>
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo)*npages);
f01011a5:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01011aa:	c1 e0 03             	shl    $0x3,%eax
f01011ad:	e8 b5 f7 ff ff       	call   f0100967 <boot_alloc>
f01011b2:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(pages,0, npages * sizeof(struct PageInfo));
f01011b7:	83 c4 0c             	add    $0xc,%esp
f01011ba:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f01011c0:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01011c7:	52                   	push   %edx
f01011c8:	6a 00                	push   $0x0
f01011ca:	50                   	push   %eax
f01011cb:	e8 c9 1f 00 00       	call   f0103199 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	cprintf("Entering page_init function.\n");
f01011d0:	c7 04 24 18 45 10 f0 	movl   $0xf0104518,(%esp)
f01011d7:	e8 04 15 00 00       	call   f01026e0 <cprintf>
	page_init();
f01011dc:	e8 60 fb ff ff       	call   f0100d41 <page_init>

	cprintf("Entering check_page_free_list function.\n");
f01011e1:	c7 04 24 f8 3d 10 f0 	movl   $0xf0103df8,(%esp)
f01011e8:	e8 f3 14 00 00       	call   f01026e0 <cprintf>
	check_page_free_list(1);
f01011ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01011f2:	e8 3f f8 ff ff       	call   f0100a36 <check_page_free_list>
	cprintf("Entering check_page_alloc function.\n");
f01011f7:	c7 04 24 24 3e 10 f0 	movl   $0xf0103e24,(%esp)
f01011fe:	e8 dd 14 00 00       	call   f01026e0 <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101203:	83 c4 10             	add    $0x10,%esp
f0101206:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f010120d:	75 17                	jne    f0101226 <mem_init+0x1ae>
		panic("'pages' is a null pointer!");
f010120f:	83 ec 04             	sub    $0x4,%esp
f0101212:	68 36 45 10 f0       	push   $0xf0104536
f0101217:	68 56 02 00 00       	push   $0x256
f010121c:	68 20 44 10 f0       	push   $0xf0104420
f0101221:	e8 ae ee ff ff       	call   f01000d4 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101226:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010122b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101230:	eb 05                	jmp    f0101237 <mem_init+0x1bf>
		++nfree;
f0101232:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101235:	8b 00                	mov    (%eax),%eax
f0101237:	85 c0                	test   %eax,%eax
f0101239:	75 f7                	jne    f0101232 <mem_init+0x1ba>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010123b:	83 ec 0c             	sub    $0xc,%esp
f010123e:	6a 00                	push   $0x0
f0101240:	e8 9f fb ff ff       	call   f0100de4 <page_alloc>
f0101245:	89 c7                	mov    %eax,%edi
f0101247:	83 c4 10             	add    $0x10,%esp
f010124a:	85 c0                	test   %eax,%eax
f010124c:	75 19                	jne    f0101267 <mem_init+0x1ef>
f010124e:	68 51 45 10 f0       	push   $0xf0104551
f0101253:	68 56 44 10 f0       	push   $0xf0104456
f0101258:	68 5e 02 00 00       	push   $0x25e
f010125d:	68 20 44 10 f0       	push   $0xf0104420
f0101262:	e8 6d ee ff ff       	call   f01000d4 <_panic>
	assert((pp1 = page_alloc(0)));
f0101267:	83 ec 0c             	sub    $0xc,%esp
f010126a:	6a 00                	push   $0x0
f010126c:	e8 73 fb ff ff       	call   f0100de4 <page_alloc>
f0101271:	89 c6                	mov    %eax,%esi
f0101273:	83 c4 10             	add    $0x10,%esp
f0101276:	85 c0                	test   %eax,%eax
f0101278:	75 19                	jne    f0101293 <mem_init+0x21b>
f010127a:	68 67 45 10 f0       	push   $0xf0104567
f010127f:	68 56 44 10 f0       	push   $0xf0104456
f0101284:	68 5f 02 00 00       	push   $0x25f
f0101289:	68 20 44 10 f0       	push   $0xf0104420
f010128e:	e8 41 ee ff ff       	call   f01000d4 <_panic>
	assert((pp2 = page_alloc(0)));
f0101293:	83 ec 0c             	sub    $0xc,%esp
f0101296:	6a 00                	push   $0x0
f0101298:	e8 47 fb ff ff       	call   f0100de4 <page_alloc>
f010129d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012a0:	83 c4 10             	add    $0x10,%esp
f01012a3:	85 c0                	test   %eax,%eax
f01012a5:	75 19                	jne    f01012c0 <mem_init+0x248>
f01012a7:	68 7d 45 10 f0       	push   $0xf010457d
f01012ac:	68 56 44 10 f0       	push   $0xf0104456
f01012b1:	68 60 02 00 00       	push   $0x260
f01012b6:	68 20 44 10 f0       	push   $0xf0104420
f01012bb:	e8 14 ee ff ff       	call   f01000d4 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012c0:	39 f7                	cmp    %esi,%edi
f01012c2:	75 19                	jne    f01012dd <mem_init+0x265>
f01012c4:	68 93 45 10 f0       	push   $0xf0104593
f01012c9:	68 56 44 10 f0       	push   $0xf0104456
f01012ce:	68 63 02 00 00       	push   $0x263
f01012d3:	68 20 44 10 f0       	push   $0xf0104420
f01012d8:	e8 f7 ed ff ff       	call   f01000d4 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012e0:	39 c6                	cmp    %eax,%esi
f01012e2:	74 04                	je     f01012e8 <mem_init+0x270>
f01012e4:	39 c7                	cmp    %eax,%edi
f01012e6:	75 19                	jne    f0101301 <mem_init+0x289>
f01012e8:	68 4c 3e 10 f0       	push   $0xf0103e4c
f01012ed:	68 56 44 10 f0       	push   $0xf0104456
f01012f2:	68 64 02 00 00       	push   $0x264
f01012f7:	68 20 44 10 f0       	push   $0xf0104420
f01012fc:	e8 d3 ed ff ff       	call   f01000d4 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101301:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101307:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f010130d:	c1 e2 0c             	shl    $0xc,%edx
f0101310:	89 f8                	mov    %edi,%eax
f0101312:	29 c8                	sub    %ecx,%eax
f0101314:	c1 f8 03             	sar    $0x3,%eax
f0101317:	c1 e0 0c             	shl    $0xc,%eax
f010131a:	39 d0                	cmp    %edx,%eax
f010131c:	72 19                	jb     f0101337 <mem_init+0x2bf>
f010131e:	68 a5 45 10 f0       	push   $0xf01045a5
f0101323:	68 56 44 10 f0       	push   $0xf0104456
f0101328:	68 65 02 00 00       	push   $0x265
f010132d:	68 20 44 10 f0       	push   $0xf0104420
f0101332:	e8 9d ed ff ff       	call   f01000d4 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101337:	89 f0                	mov    %esi,%eax
f0101339:	29 c8                	sub    %ecx,%eax
f010133b:	c1 f8 03             	sar    $0x3,%eax
f010133e:	c1 e0 0c             	shl    $0xc,%eax
f0101341:	39 c2                	cmp    %eax,%edx
f0101343:	77 19                	ja     f010135e <mem_init+0x2e6>
f0101345:	68 c2 45 10 f0       	push   $0xf01045c2
f010134a:	68 56 44 10 f0       	push   $0xf0104456
f010134f:	68 66 02 00 00       	push   $0x266
f0101354:	68 20 44 10 f0       	push   $0xf0104420
f0101359:	e8 76 ed ff ff       	call   f01000d4 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010135e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101361:	29 c8                	sub    %ecx,%eax
f0101363:	c1 f8 03             	sar    $0x3,%eax
f0101366:	c1 e0 0c             	shl    $0xc,%eax
f0101369:	39 c2                	cmp    %eax,%edx
f010136b:	77 19                	ja     f0101386 <mem_init+0x30e>
f010136d:	68 df 45 10 f0       	push   $0xf01045df
f0101372:	68 56 44 10 f0       	push   $0xf0104456
f0101377:	68 67 02 00 00       	push   $0x267
f010137c:	68 20 44 10 f0       	push   $0xf0104420
f0101381:	e8 4e ed ff ff       	call   f01000d4 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101386:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010138b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010138e:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101395:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101398:	83 ec 0c             	sub    $0xc,%esp
f010139b:	6a 00                	push   $0x0
f010139d:	e8 42 fa ff ff       	call   f0100de4 <page_alloc>
f01013a2:	83 c4 10             	add    $0x10,%esp
f01013a5:	85 c0                	test   %eax,%eax
f01013a7:	74 19                	je     f01013c2 <mem_init+0x34a>
f01013a9:	68 fc 45 10 f0       	push   $0xf01045fc
f01013ae:	68 56 44 10 f0       	push   $0xf0104456
f01013b3:	68 6e 02 00 00       	push   $0x26e
f01013b8:	68 20 44 10 f0       	push   $0xf0104420
f01013bd:	e8 12 ed ff ff       	call   f01000d4 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013c2:	83 ec 0c             	sub    $0xc,%esp
f01013c5:	57                   	push   %edi
f01013c6:	e8 a9 fa ff ff       	call   f0100e74 <page_free>
	page_free(pp1);
f01013cb:	89 34 24             	mov    %esi,(%esp)
f01013ce:	e8 a1 fa ff ff       	call   f0100e74 <page_free>
	page_free(pp2);
f01013d3:	83 c4 04             	add    $0x4,%esp
f01013d6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013d9:	e8 96 fa ff ff       	call   f0100e74 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013e5:	e8 fa f9 ff ff       	call   f0100de4 <page_alloc>
f01013ea:	89 c6                	mov    %eax,%esi
f01013ec:	83 c4 10             	add    $0x10,%esp
f01013ef:	85 c0                	test   %eax,%eax
f01013f1:	75 19                	jne    f010140c <mem_init+0x394>
f01013f3:	68 51 45 10 f0       	push   $0xf0104551
f01013f8:	68 56 44 10 f0       	push   $0xf0104456
f01013fd:	68 75 02 00 00       	push   $0x275
f0101402:	68 20 44 10 f0       	push   $0xf0104420
f0101407:	e8 c8 ec ff ff       	call   f01000d4 <_panic>
	assert((pp1 = page_alloc(0)));
f010140c:	83 ec 0c             	sub    $0xc,%esp
f010140f:	6a 00                	push   $0x0
f0101411:	e8 ce f9 ff ff       	call   f0100de4 <page_alloc>
f0101416:	89 c7                	mov    %eax,%edi
f0101418:	83 c4 10             	add    $0x10,%esp
f010141b:	85 c0                	test   %eax,%eax
f010141d:	75 19                	jne    f0101438 <mem_init+0x3c0>
f010141f:	68 67 45 10 f0       	push   $0xf0104567
f0101424:	68 56 44 10 f0       	push   $0xf0104456
f0101429:	68 76 02 00 00       	push   $0x276
f010142e:	68 20 44 10 f0       	push   $0xf0104420
f0101433:	e8 9c ec ff ff       	call   f01000d4 <_panic>
	assert((pp2 = page_alloc(0)));
f0101438:	83 ec 0c             	sub    $0xc,%esp
f010143b:	6a 00                	push   $0x0
f010143d:	e8 a2 f9 ff ff       	call   f0100de4 <page_alloc>
f0101442:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101445:	83 c4 10             	add    $0x10,%esp
f0101448:	85 c0                	test   %eax,%eax
f010144a:	75 19                	jne    f0101465 <mem_init+0x3ed>
f010144c:	68 7d 45 10 f0       	push   $0xf010457d
f0101451:	68 56 44 10 f0       	push   $0xf0104456
f0101456:	68 77 02 00 00       	push   $0x277
f010145b:	68 20 44 10 f0       	push   $0xf0104420
f0101460:	e8 6f ec ff ff       	call   f01000d4 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101465:	39 fe                	cmp    %edi,%esi
f0101467:	75 19                	jne    f0101482 <mem_init+0x40a>
f0101469:	68 93 45 10 f0       	push   $0xf0104593
f010146e:	68 56 44 10 f0       	push   $0xf0104456
f0101473:	68 79 02 00 00       	push   $0x279
f0101478:	68 20 44 10 f0       	push   $0xf0104420
f010147d:	e8 52 ec ff ff       	call   f01000d4 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101482:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101485:	39 c7                	cmp    %eax,%edi
f0101487:	74 04                	je     f010148d <mem_init+0x415>
f0101489:	39 c6                	cmp    %eax,%esi
f010148b:	75 19                	jne    f01014a6 <mem_init+0x42e>
f010148d:	68 4c 3e 10 f0       	push   $0xf0103e4c
f0101492:	68 56 44 10 f0       	push   $0xf0104456
f0101497:	68 7a 02 00 00       	push   $0x27a
f010149c:	68 20 44 10 f0       	push   $0xf0104420
f01014a1:	e8 2e ec ff ff       	call   f01000d4 <_panic>
	assert(!page_alloc(0));
f01014a6:	83 ec 0c             	sub    $0xc,%esp
f01014a9:	6a 00                	push   $0x0
f01014ab:	e8 34 f9 ff ff       	call   f0100de4 <page_alloc>
f01014b0:	83 c4 10             	add    $0x10,%esp
f01014b3:	85 c0                	test   %eax,%eax
f01014b5:	74 19                	je     f01014d0 <mem_init+0x458>
f01014b7:	68 fc 45 10 f0       	push   $0xf01045fc
f01014bc:	68 56 44 10 f0       	push   $0xf0104456
f01014c1:	68 7b 02 00 00       	push   $0x27b
f01014c6:	68 20 44 10 f0       	push   $0xf0104420
f01014cb:	e8 04 ec ff ff       	call   f01000d4 <_panic>
f01014d0:	89 f0                	mov    %esi,%eax
f01014d2:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01014d8:	c1 f8 03             	sar    $0x3,%eax
f01014db:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014de:	89 c2                	mov    %eax,%edx
f01014e0:	c1 ea 0c             	shr    $0xc,%edx
f01014e3:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01014e9:	72 12                	jb     f01014fd <mem_init+0x485>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014eb:	50                   	push   %eax
f01014ec:	68 10 3c 10 f0       	push   $0xf0103c10
f01014f1:	6a 52                	push   $0x52
f01014f3:	68 34 44 10 f0       	push   $0xf0104434
f01014f8:	e8 d7 eb ff ff       	call   f01000d4 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01014fd:	83 ec 04             	sub    $0x4,%esp
f0101500:	68 00 10 00 00       	push   $0x1000
f0101505:	6a 01                	push   $0x1
f0101507:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010150c:	50                   	push   %eax
f010150d:	e8 87 1c 00 00       	call   f0103199 <memset>
	page_free(pp0);
f0101512:	89 34 24             	mov    %esi,(%esp)
f0101515:	e8 5a f9 ff ff       	call   f0100e74 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010151a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101521:	e8 be f8 ff ff       	call   f0100de4 <page_alloc>
f0101526:	83 c4 10             	add    $0x10,%esp
f0101529:	85 c0                	test   %eax,%eax
f010152b:	75 19                	jne    f0101546 <mem_init+0x4ce>
f010152d:	68 0b 46 10 f0       	push   $0xf010460b
f0101532:	68 56 44 10 f0       	push   $0xf0104456
f0101537:	68 80 02 00 00       	push   $0x280
f010153c:	68 20 44 10 f0       	push   $0xf0104420
f0101541:	e8 8e eb ff ff       	call   f01000d4 <_panic>
	assert(pp && pp0 == pp);
f0101546:	39 c6                	cmp    %eax,%esi
f0101548:	74 19                	je     f0101563 <mem_init+0x4eb>
f010154a:	68 29 46 10 f0       	push   $0xf0104629
f010154f:	68 56 44 10 f0       	push   $0xf0104456
f0101554:	68 81 02 00 00       	push   $0x281
f0101559:	68 20 44 10 f0       	push   $0xf0104420
f010155e:	e8 71 eb ff ff       	call   f01000d4 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101563:	89 f0                	mov    %esi,%eax
f0101565:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010156b:	c1 f8 03             	sar    $0x3,%eax
f010156e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101571:	89 c2                	mov    %eax,%edx
f0101573:	c1 ea 0c             	shr    $0xc,%edx
f0101576:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f010157c:	72 12                	jb     f0101590 <mem_init+0x518>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010157e:	50                   	push   %eax
f010157f:	68 10 3c 10 f0       	push   $0xf0103c10
f0101584:	6a 52                	push   $0x52
f0101586:	68 34 44 10 f0       	push   $0xf0104434
f010158b:	e8 44 eb ff ff       	call   f01000d4 <_panic>
f0101590:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101596:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010159c:	80 38 00             	cmpb   $0x0,(%eax)
f010159f:	74 19                	je     f01015ba <mem_init+0x542>
f01015a1:	68 39 46 10 f0       	push   $0xf0104639
f01015a6:	68 56 44 10 f0       	push   $0xf0104456
f01015ab:	68 84 02 00 00       	push   $0x284
f01015b0:	68 20 44 10 f0       	push   $0xf0104420
f01015b5:	e8 1a eb ff ff       	call   f01000d4 <_panic>
f01015ba:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01015bd:	39 d0                	cmp    %edx,%eax
f01015bf:	75 db                	jne    f010159c <mem_init+0x524>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01015c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015c4:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01015c9:	83 ec 0c             	sub    $0xc,%esp
f01015cc:	56                   	push   %esi
f01015cd:	e8 a2 f8 ff ff       	call   f0100e74 <page_free>
	page_free(pp1);
f01015d2:	89 3c 24             	mov    %edi,(%esp)
f01015d5:	e8 9a f8 ff ff       	call   f0100e74 <page_free>
	page_free(pp2);
f01015da:	83 c4 04             	add    $0x4,%esp
f01015dd:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015e0:	e8 8f f8 ff ff       	call   f0100e74 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015e5:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01015ea:	83 c4 10             	add    $0x10,%esp
f01015ed:	eb 05                	jmp    f01015f4 <mem_init+0x57c>
		--nfree;
f01015ef:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015f2:	8b 00                	mov    (%eax),%eax
f01015f4:	85 c0                	test   %eax,%eax
f01015f6:	75 f7                	jne    f01015ef <mem_init+0x577>
		--nfree;
	assert(nfree == 0);
f01015f8:	85 db                	test   %ebx,%ebx
f01015fa:	74 19                	je     f0101615 <mem_init+0x59d>
f01015fc:	68 43 46 10 f0       	push   $0xf0104643
f0101601:	68 56 44 10 f0       	push   $0xf0104456
f0101606:	68 91 02 00 00       	push   $0x291
f010160b:	68 20 44 10 f0       	push   $0xf0104420
f0101610:	e8 bf ea ff ff       	call   f01000d4 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101615:	83 ec 0c             	sub    $0xc,%esp
f0101618:	68 6c 3e 10 f0       	push   $0xf0103e6c
f010161d:	e8 be 10 00 00       	call   f01026e0 <cprintf>

	cprintf("Entering check_page_free_list function.\n");
	check_page_free_list(1);
	cprintf("Entering check_page_alloc function.\n");
	check_page_alloc();
	cprintf("Entering check_page function.\n");
f0101622:	c7 04 24 8c 3e 10 f0 	movl   $0xf0103e8c,(%esp)
f0101629:	e8 b2 10 00 00       	call   f01026e0 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010162e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101635:	e8 aa f7 ff ff       	call   f0100de4 <page_alloc>
f010163a:	89 c6                	mov    %eax,%esi
f010163c:	83 c4 10             	add    $0x10,%esp
f010163f:	85 c0                	test   %eax,%eax
f0101641:	75 19                	jne    f010165c <mem_init+0x5e4>
f0101643:	68 51 45 10 f0       	push   $0xf0104551
f0101648:	68 56 44 10 f0       	push   $0xf0104456
f010164d:	68 ea 02 00 00       	push   $0x2ea
f0101652:	68 20 44 10 f0       	push   $0xf0104420
f0101657:	e8 78 ea ff ff       	call   f01000d4 <_panic>
	assert((pp1 = page_alloc(0)));
f010165c:	83 ec 0c             	sub    $0xc,%esp
f010165f:	6a 00                	push   $0x0
f0101661:	e8 7e f7 ff ff       	call   f0100de4 <page_alloc>
f0101666:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101669:	83 c4 10             	add    $0x10,%esp
f010166c:	85 c0                	test   %eax,%eax
f010166e:	75 19                	jne    f0101689 <mem_init+0x611>
f0101670:	68 67 45 10 f0       	push   $0xf0104567
f0101675:	68 56 44 10 f0       	push   $0xf0104456
f010167a:	68 eb 02 00 00       	push   $0x2eb
f010167f:	68 20 44 10 f0       	push   $0xf0104420
f0101684:	e8 4b ea ff ff       	call   f01000d4 <_panic>
	assert((pp2 = page_alloc(0)));
f0101689:	83 ec 0c             	sub    $0xc,%esp
f010168c:	6a 00                	push   $0x0
f010168e:	e8 51 f7 ff ff       	call   f0100de4 <page_alloc>
f0101693:	89 c3                	mov    %eax,%ebx
f0101695:	83 c4 10             	add    $0x10,%esp
f0101698:	85 c0                	test   %eax,%eax
f010169a:	75 19                	jne    f01016b5 <mem_init+0x63d>
f010169c:	68 7d 45 10 f0       	push   $0xf010457d
f01016a1:	68 56 44 10 f0       	push   $0xf0104456
f01016a6:	68 ec 02 00 00       	push   $0x2ec
f01016ab:	68 20 44 10 f0       	push   $0xf0104420
f01016b0:	e8 1f ea ff ff       	call   f01000d4 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016b5:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01016b8:	75 19                	jne    f01016d3 <mem_init+0x65b>
f01016ba:	68 93 45 10 f0       	push   $0xf0104593
f01016bf:	68 56 44 10 f0       	push   $0xf0104456
f01016c4:	68 ef 02 00 00       	push   $0x2ef
f01016c9:	68 20 44 10 f0       	push   $0xf0104420
f01016ce:	e8 01 ea ff ff       	call   f01000d4 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016d3:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016d6:	74 04                	je     f01016dc <mem_init+0x664>
f01016d8:	39 c6                	cmp    %eax,%esi
f01016da:	75 19                	jne    f01016f5 <mem_init+0x67d>
f01016dc:	68 4c 3e 10 f0       	push   $0xf0103e4c
f01016e1:	68 56 44 10 f0       	push   $0xf0104456
f01016e6:	68 f0 02 00 00       	push   $0x2f0
f01016eb:	68 20 44 10 f0       	push   $0xf0104420
f01016f0:	e8 df e9 ff ff       	call   f01000d4 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016f5:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01016fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016fd:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101704:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101707:	83 ec 0c             	sub    $0xc,%esp
f010170a:	6a 00                	push   $0x0
f010170c:	e8 d3 f6 ff ff       	call   f0100de4 <page_alloc>
f0101711:	83 c4 10             	add    $0x10,%esp
f0101714:	85 c0                	test   %eax,%eax
f0101716:	74 19                	je     f0101731 <mem_init+0x6b9>
f0101718:	68 fc 45 10 f0       	push   $0xf01045fc
f010171d:	68 56 44 10 f0       	push   $0xf0104456
f0101722:	68 f7 02 00 00       	push   $0x2f7
f0101727:	68 20 44 10 f0       	push   $0xf0104420
f010172c:	e8 a3 e9 ff ff       	call   f01000d4 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101731:	83 ec 04             	sub    $0x4,%esp
f0101734:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101737:	50                   	push   %eax
f0101738:	6a 00                	push   $0x0
f010173a:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101740:	e8 31 f8 ff ff       	call   f0100f76 <page_lookup>
f0101745:	83 c4 10             	add    $0x10,%esp
f0101748:	85 c0                	test   %eax,%eax
f010174a:	74 19                	je     f0101765 <mem_init+0x6ed>
f010174c:	68 ac 3e 10 f0       	push   $0xf0103eac
f0101751:	68 56 44 10 f0       	push   $0xf0104456
f0101756:	68 fa 02 00 00       	push   $0x2fa
f010175b:	68 20 44 10 f0       	push   $0xf0104420
f0101760:	e8 6f e9 ff ff       	call   f01000d4 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101765:	6a 02                	push   $0x2
f0101767:	6a 00                	push   $0x0
f0101769:	ff 75 d4             	pushl  -0x2c(%ebp)
f010176c:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101772:	e8 94 f8 ff ff       	call   f010100b <page_insert>
f0101777:	83 c4 10             	add    $0x10,%esp
f010177a:	85 c0                	test   %eax,%eax
f010177c:	78 19                	js     f0101797 <mem_init+0x71f>
f010177e:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0101783:	68 56 44 10 f0       	push   $0xf0104456
f0101788:	68 fd 02 00 00       	push   $0x2fd
f010178d:	68 20 44 10 f0       	push   $0xf0104420
f0101792:	e8 3d e9 ff ff       	call   f01000d4 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101797:	83 ec 0c             	sub    $0xc,%esp
f010179a:	56                   	push   %esi
f010179b:	e8 d4 f6 ff ff       	call   f0100e74 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017a0:	6a 02                	push   $0x2
f01017a2:	6a 00                	push   $0x0
f01017a4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017a7:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01017ad:	e8 59 f8 ff ff       	call   f010100b <page_insert>
f01017b2:	83 c4 20             	add    $0x20,%esp
f01017b5:	85 c0                	test   %eax,%eax
f01017b7:	74 19                	je     f01017d2 <mem_init+0x75a>
f01017b9:	68 14 3f 10 f0       	push   $0xf0103f14
f01017be:	68 56 44 10 f0       	push   $0xf0104456
f01017c3:	68 01 03 00 00       	push   $0x301
f01017c8:	68 20 44 10 f0       	push   $0xf0104420
f01017cd:	e8 02 e9 ff ff       	call   f01000d4 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017d2:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017d8:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01017dd:	89 c1                	mov    %eax,%ecx
f01017df:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017e2:	8b 17                	mov    (%edi),%edx
f01017e4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017ea:	89 f0                	mov    %esi,%eax
f01017ec:	29 c8                	sub    %ecx,%eax
f01017ee:	c1 f8 03             	sar    $0x3,%eax
f01017f1:	c1 e0 0c             	shl    $0xc,%eax
f01017f4:	39 c2                	cmp    %eax,%edx
f01017f6:	74 19                	je     f0101811 <mem_init+0x799>
f01017f8:	68 44 3f 10 f0       	push   $0xf0103f44
f01017fd:	68 56 44 10 f0       	push   $0xf0104456
f0101802:	68 02 03 00 00       	push   $0x302
f0101807:	68 20 44 10 f0       	push   $0xf0104420
f010180c:	e8 c3 e8 ff ff       	call   f01000d4 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101811:	ba 00 00 00 00       	mov    $0x0,%edx
f0101816:	89 f8                	mov    %edi,%eax
f0101818:	e8 b5 f1 ff ff       	call   f01009d2 <check_va2pa>
f010181d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101820:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101823:	c1 fa 03             	sar    $0x3,%edx
f0101826:	c1 e2 0c             	shl    $0xc,%edx
f0101829:	39 d0                	cmp    %edx,%eax
f010182b:	74 19                	je     f0101846 <mem_init+0x7ce>
f010182d:	68 6c 3f 10 f0       	push   $0xf0103f6c
f0101832:	68 56 44 10 f0       	push   $0xf0104456
f0101837:	68 03 03 00 00       	push   $0x303
f010183c:	68 20 44 10 f0       	push   $0xf0104420
f0101841:	e8 8e e8 ff ff       	call   f01000d4 <_panic>
	assert(pp1->pp_ref == 1);
f0101846:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101849:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010184e:	74 19                	je     f0101869 <mem_init+0x7f1>
f0101850:	68 4e 46 10 f0       	push   $0xf010464e
f0101855:	68 56 44 10 f0       	push   $0xf0104456
f010185a:	68 04 03 00 00       	push   $0x304
f010185f:	68 20 44 10 f0       	push   $0xf0104420
f0101864:	e8 6b e8 ff ff       	call   f01000d4 <_panic>
	assert(pp0->pp_ref == 1);
f0101869:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010186e:	74 19                	je     f0101889 <mem_init+0x811>
f0101870:	68 5f 46 10 f0       	push   $0xf010465f
f0101875:	68 56 44 10 f0       	push   $0xf0104456
f010187a:	68 05 03 00 00       	push   $0x305
f010187f:	68 20 44 10 f0       	push   $0xf0104420
f0101884:	e8 4b e8 ff ff       	call   f01000d4 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101889:	6a 02                	push   $0x2
f010188b:	68 00 10 00 00       	push   $0x1000
f0101890:	53                   	push   %ebx
f0101891:	57                   	push   %edi
f0101892:	e8 74 f7 ff ff       	call   f010100b <page_insert>
f0101897:	83 c4 10             	add    $0x10,%esp
f010189a:	85 c0                	test   %eax,%eax
f010189c:	74 19                	je     f01018b7 <mem_init+0x83f>
f010189e:	68 9c 3f 10 f0       	push   $0xf0103f9c
f01018a3:	68 56 44 10 f0       	push   $0xf0104456
f01018a8:	68 08 03 00 00       	push   $0x308
f01018ad:	68 20 44 10 f0       	push   $0xf0104420
f01018b2:	e8 1d e8 ff ff       	call   f01000d4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018b7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018bc:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01018c1:	e8 0c f1 ff ff       	call   f01009d2 <check_va2pa>
f01018c6:	89 da                	mov    %ebx,%edx
f01018c8:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01018ce:	c1 fa 03             	sar    $0x3,%edx
f01018d1:	c1 e2 0c             	shl    $0xc,%edx
f01018d4:	39 d0                	cmp    %edx,%eax
f01018d6:	74 19                	je     f01018f1 <mem_init+0x879>
f01018d8:	68 d8 3f 10 f0       	push   $0xf0103fd8
f01018dd:	68 56 44 10 f0       	push   $0xf0104456
f01018e2:	68 09 03 00 00       	push   $0x309
f01018e7:	68 20 44 10 f0       	push   $0xf0104420
f01018ec:	e8 e3 e7 ff ff       	call   f01000d4 <_panic>
	assert(pp2->pp_ref == 1);
f01018f1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018f6:	74 19                	je     f0101911 <mem_init+0x899>
f01018f8:	68 70 46 10 f0       	push   $0xf0104670
f01018fd:	68 56 44 10 f0       	push   $0xf0104456
f0101902:	68 0a 03 00 00       	push   $0x30a
f0101907:	68 20 44 10 f0       	push   $0xf0104420
f010190c:	e8 c3 e7 ff ff       	call   f01000d4 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101911:	83 ec 0c             	sub    $0xc,%esp
f0101914:	6a 00                	push   $0x0
f0101916:	e8 c9 f4 ff ff       	call   f0100de4 <page_alloc>
f010191b:	83 c4 10             	add    $0x10,%esp
f010191e:	85 c0                	test   %eax,%eax
f0101920:	74 19                	je     f010193b <mem_init+0x8c3>
f0101922:	68 fc 45 10 f0       	push   $0xf01045fc
f0101927:	68 56 44 10 f0       	push   $0xf0104456
f010192c:	68 0d 03 00 00       	push   $0x30d
f0101931:	68 20 44 10 f0       	push   $0xf0104420
f0101936:	e8 99 e7 ff ff       	call   f01000d4 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010193b:	6a 02                	push   $0x2
f010193d:	68 00 10 00 00       	push   $0x1000
f0101942:	53                   	push   %ebx
f0101943:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101949:	e8 bd f6 ff ff       	call   f010100b <page_insert>
f010194e:	83 c4 10             	add    $0x10,%esp
f0101951:	85 c0                	test   %eax,%eax
f0101953:	74 19                	je     f010196e <mem_init+0x8f6>
f0101955:	68 9c 3f 10 f0       	push   $0xf0103f9c
f010195a:	68 56 44 10 f0       	push   $0xf0104456
f010195f:	68 10 03 00 00       	push   $0x310
f0101964:	68 20 44 10 f0       	push   $0xf0104420
f0101969:	e8 66 e7 ff ff       	call   f01000d4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010196e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101973:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101978:	e8 55 f0 ff ff       	call   f01009d2 <check_va2pa>
f010197d:	89 da                	mov    %ebx,%edx
f010197f:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101985:	c1 fa 03             	sar    $0x3,%edx
f0101988:	c1 e2 0c             	shl    $0xc,%edx
f010198b:	39 d0                	cmp    %edx,%eax
f010198d:	74 19                	je     f01019a8 <mem_init+0x930>
f010198f:	68 d8 3f 10 f0       	push   $0xf0103fd8
f0101994:	68 56 44 10 f0       	push   $0xf0104456
f0101999:	68 11 03 00 00       	push   $0x311
f010199e:	68 20 44 10 f0       	push   $0xf0104420
f01019a3:	e8 2c e7 ff ff       	call   f01000d4 <_panic>
	assert(pp2->pp_ref == 1);
f01019a8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019ad:	74 19                	je     f01019c8 <mem_init+0x950>
f01019af:	68 70 46 10 f0       	push   $0xf0104670
f01019b4:	68 56 44 10 f0       	push   $0xf0104456
f01019b9:	68 12 03 00 00       	push   $0x312
f01019be:	68 20 44 10 f0       	push   $0xf0104420
f01019c3:	e8 0c e7 ff ff       	call   f01000d4 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019c8:	83 ec 0c             	sub    $0xc,%esp
f01019cb:	6a 00                	push   $0x0
f01019cd:	e8 12 f4 ff ff       	call   f0100de4 <page_alloc>
f01019d2:	83 c4 10             	add    $0x10,%esp
f01019d5:	85 c0                	test   %eax,%eax
f01019d7:	74 19                	je     f01019f2 <mem_init+0x97a>
f01019d9:	68 fc 45 10 f0       	push   $0xf01045fc
f01019de:	68 56 44 10 f0       	push   $0xf0104456
f01019e3:	68 16 03 00 00       	push   $0x316
f01019e8:	68 20 44 10 f0       	push   $0xf0104420
f01019ed:	e8 e2 e6 ff ff       	call   f01000d4 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019f2:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f01019f8:	8b 02                	mov    (%edx),%eax
f01019fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019ff:	89 c1                	mov    %eax,%ecx
f0101a01:	c1 e9 0c             	shr    $0xc,%ecx
f0101a04:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0101a0a:	72 15                	jb     f0101a21 <mem_init+0x9a9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a0c:	50                   	push   %eax
f0101a0d:	68 10 3c 10 f0       	push   $0xf0103c10
f0101a12:	68 19 03 00 00       	push   $0x319
f0101a17:	68 20 44 10 f0       	push   $0xf0104420
f0101a1c:	e8 b3 e6 ff ff       	call   f01000d4 <_panic>
f0101a21:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a29:	83 ec 04             	sub    $0x4,%esp
f0101a2c:	6a 00                	push   $0x0
f0101a2e:	68 00 10 00 00       	push   $0x1000
f0101a33:	52                   	push   %edx
f0101a34:	e8 9a f4 ff ff       	call   f0100ed3 <pgdir_walk>
f0101a39:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a3c:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a3f:	83 c4 10             	add    $0x10,%esp
f0101a42:	39 d0                	cmp    %edx,%eax
f0101a44:	74 19                	je     f0101a5f <mem_init+0x9e7>
f0101a46:	68 08 40 10 f0       	push   $0xf0104008
f0101a4b:	68 56 44 10 f0       	push   $0xf0104456
f0101a50:	68 1a 03 00 00       	push   $0x31a
f0101a55:	68 20 44 10 f0       	push   $0xf0104420
f0101a5a:	e8 75 e6 ff ff       	call   f01000d4 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a5f:	6a 06                	push   $0x6
f0101a61:	68 00 10 00 00       	push   $0x1000
f0101a66:	53                   	push   %ebx
f0101a67:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101a6d:	e8 99 f5 ff ff       	call   f010100b <page_insert>
f0101a72:	83 c4 10             	add    $0x10,%esp
f0101a75:	85 c0                	test   %eax,%eax
f0101a77:	74 19                	je     f0101a92 <mem_init+0xa1a>
f0101a79:	68 48 40 10 f0       	push   $0xf0104048
f0101a7e:	68 56 44 10 f0       	push   $0xf0104456
f0101a83:	68 1d 03 00 00       	push   $0x31d
f0101a88:	68 20 44 10 f0       	push   $0xf0104420
f0101a8d:	e8 42 e6 ff ff       	call   f01000d4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a92:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101a98:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a9d:	89 f8                	mov    %edi,%eax
f0101a9f:	e8 2e ef ff ff       	call   f01009d2 <check_va2pa>
f0101aa4:	89 da                	mov    %ebx,%edx
f0101aa6:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101aac:	c1 fa 03             	sar    $0x3,%edx
f0101aaf:	c1 e2 0c             	shl    $0xc,%edx
f0101ab2:	39 d0                	cmp    %edx,%eax
f0101ab4:	74 19                	je     f0101acf <mem_init+0xa57>
f0101ab6:	68 d8 3f 10 f0       	push   $0xf0103fd8
f0101abb:	68 56 44 10 f0       	push   $0xf0104456
f0101ac0:	68 1e 03 00 00       	push   $0x31e
f0101ac5:	68 20 44 10 f0       	push   $0xf0104420
f0101aca:	e8 05 e6 ff ff       	call   f01000d4 <_panic>
	assert(pp2->pp_ref == 1);
f0101acf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ad4:	74 19                	je     f0101aef <mem_init+0xa77>
f0101ad6:	68 70 46 10 f0       	push   $0xf0104670
f0101adb:	68 56 44 10 f0       	push   $0xf0104456
f0101ae0:	68 1f 03 00 00       	push   $0x31f
f0101ae5:	68 20 44 10 f0       	push   $0xf0104420
f0101aea:	e8 e5 e5 ff ff       	call   f01000d4 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101aef:	83 ec 04             	sub    $0x4,%esp
f0101af2:	6a 00                	push   $0x0
f0101af4:	68 00 10 00 00       	push   $0x1000
f0101af9:	57                   	push   %edi
f0101afa:	e8 d4 f3 ff ff       	call   f0100ed3 <pgdir_walk>
f0101aff:	83 c4 10             	add    $0x10,%esp
f0101b02:	f6 00 04             	testb  $0x4,(%eax)
f0101b05:	75 19                	jne    f0101b20 <mem_init+0xaa8>
f0101b07:	68 88 40 10 f0       	push   $0xf0104088
f0101b0c:	68 56 44 10 f0       	push   $0xf0104456
f0101b11:	68 20 03 00 00       	push   $0x320
f0101b16:	68 20 44 10 f0       	push   $0xf0104420
f0101b1b:	e8 b4 e5 ff ff       	call   f01000d4 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b20:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101b25:	f6 00 04             	testb  $0x4,(%eax)
f0101b28:	75 19                	jne    f0101b43 <mem_init+0xacb>
f0101b2a:	68 81 46 10 f0       	push   $0xf0104681
f0101b2f:	68 56 44 10 f0       	push   $0xf0104456
f0101b34:	68 21 03 00 00       	push   $0x321
f0101b39:	68 20 44 10 f0       	push   $0xf0104420
f0101b3e:	e8 91 e5 ff ff       	call   f01000d4 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b43:	6a 02                	push   $0x2
f0101b45:	68 00 10 00 00       	push   $0x1000
f0101b4a:	53                   	push   %ebx
f0101b4b:	50                   	push   %eax
f0101b4c:	e8 ba f4 ff ff       	call   f010100b <page_insert>
f0101b51:	83 c4 10             	add    $0x10,%esp
f0101b54:	85 c0                	test   %eax,%eax
f0101b56:	74 19                	je     f0101b71 <mem_init+0xaf9>
f0101b58:	68 9c 3f 10 f0       	push   $0xf0103f9c
f0101b5d:	68 56 44 10 f0       	push   $0xf0104456
f0101b62:	68 24 03 00 00       	push   $0x324
f0101b67:	68 20 44 10 f0       	push   $0xf0104420
f0101b6c:	e8 63 e5 ff ff       	call   f01000d4 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b71:	83 ec 04             	sub    $0x4,%esp
f0101b74:	6a 00                	push   $0x0
f0101b76:	68 00 10 00 00       	push   $0x1000
f0101b7b:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101b81:	e8 4d f3 ff ff       	call   f0100ed3 <pgdir_walk>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	f6 00 02             	testb  $0x2,(%eax)
f0101b8c:	75 19                	jne    f0101ba7 <mem_init+0xb2f>
f0101b8e:	68 bc 40 10 f0       	push   $0xf01040bc
f0101b93:	68 56 44 10 f0       	push   $0xf0104456
f0101b98:	68 25 03 00 00       	push   $0x325
f0101b9d:	68 20 44 10 f0       	push   $0xf0104420
f0101ba2:	e8 2d e5 ff ff       	call   f01000d4 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ba7:	83 ec 04             	sub    $0x4,%esp
f0101baa:	6a 00                	push   $0x0
f0101bac:	68 00 10 00 00       	push   $0x1000
f0101bb1:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101bb7:	e8 17 f3 ff ff       	call   f0100ed3 <pgdir_walk>
f0101bbc:	83 c4 10             	add    $0x10,%esp
f0101bbf:	f6 00 04             	testb  $0x4,(%eax)
f0101bc2:	74 19                	je     f0101bdd <mem_init+0xb65>
f0101bc4:	68 f0 40 10 f0       	push   $0xf01040f0
f0101bc9:	68 56 44 10 f0       	push   $0xf0104456
f0101bce:	68 26 03 00 00       	push   $0x326
f0101bd3:	68 20 44 10 f0       	push   $0xf0104420
f0101bd8:	e8 f7 e4 ff ff       	call   f01000d4 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bdd:	6a 02                	push   $0x2
f0101bdf:	68 00 00 40 00       	push   $0x400000
f0101be4:	56                   	push   %esi
f0101be5:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101beb:	e8 1b f4 ff ff       	call   f010100b <page_insert>
f0101bf0:	83 c4 10             	add    $0x10,%esp
f0101bf3:	85 c0                	test   %eax,%eax
f0101bf5:	78 19                	js     f0101c10 <mem_init+0xb98>
f0101bf7:	68 28 41 10 f0       	push   $0xf0104128
f0101bfc:	68 56 44 10 f0       	push   $0xf0104456
f0101c01:	68 29 03 00 00       	push   $0x329
f0101c06:	68 20 44 10 f0       	push   $0xf0104420
f0101c0b:	e8 c4 e4 ff ff       	call   f01000d4 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c10:	6a 02                	push   $0x2
f0101c12:	68 00 10 00 00       	push   $0x1000
f0101c17:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c1a:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101c20:	e8 e6 f3 ff ff       	call   f010100b <page_insert>
f0101c25:	83 c4 10             	add    $0x10,%esp
f0101c28:	85 c0                	test   %eax,%eax
f0101c2a:	74 19                	je     f0101c45 <mem_init+0xbcd>
f0101c2c:	68 60 41 10 f0       	push   $0xf0104160
f0101c31:	68 56 44 10 f0       	push   $0xf0104456
f0101c36:	68 2c 03 00 00       	push   $0x32c
f0101c3b:	68 20 44 10 f0       	push   $0xf0104420
f0101c40:	e8 8f e4 ff ff       	call   f01000d4 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c45:	83 ec 04             	sub    $0x4,%esp
f0101c48:	6a 00                	push   $0x0
f0101c4a:	68 00 10 00 00       	push   $0x1000
f0101c4f:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101c55:	e8 79 f2 ff ff       	call   f0100ed3 <pgdir_walk>
f0101c5a:	83 c4 10             	add    $0x10,%esp
f0101c5d:	f6 00 04             	testb  $0x4,(%eax)
f0101c60:	74 19                	je     f0101c7b <mem_init+0xc03>
f0101c62:	68 f0 40 10 f0       	push   $0xf01040f0
f0101c67:	68 56 44 10 f0       	push   $0xf0104456
f0101c6c:	68 2d 03 00 00       	push   $0x32d
f0101c71:	68 20 44 10 f0       	push   $0xf0104420
f0101c76:	e8 59 e4 ff ff       	call   f01000d4 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c7b:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101c81:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c86:	89 f8                	mov    %edi,%eax
f0101c88:	e8 45 ed ff ff       	call   f01009d2 <check_va2pa>
f0101c8d:	89 c1                	mov    %eax,%ecx
f0101c8f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c95:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101c9b:	c1 f8 03             	sar    $0x3,%eax
f0101c9e:	c1 e0 0c             	shl    $0xc,%eax
f0101ca1:	39 c1                	cmp    %eax,%ecx
f0101ca3:	74 19                	je     f0101cbe <mem_init+0xc46>
f0101ca5:	68 9c 41 10 f0       	push   $0xf010419c
f0101caa:	68 56 44 10 f0       	push   $0xf0104456
f0101caf:	68 30 03 00 00       	push   $0x330
f0101cb4:	68 20 44 10 f0       	push   $0xf0104420
f0101cb9:	e8 16 e4 ff ff       	call   f01000d4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cbe:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc3:	89 f8                	mov    %edi,%eax
f0101cc5:	e8 08 ed ff ff       	call   f01009d2 <check_va2pa>
f0101cca:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ccd:	74 19                	je     f0101ce8 <mem_init+0xc70>
f0101ccf:	68 c8 41 10 f0       	push   $0xf01041c8
f0101cd4:	68 56 44 10 f0       	push   $0xf0104456
f0101cd9:	68 31 03 00 00       	push   $0x331
f0101cde:	68 20 44 10 f0       	push   $0xf0104420
f0101ce3:	e8 ec e3 ff ff       	call   f01000d4 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ce8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ceb:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101cf0:	74 19                	je     f0101d0b <mem_init+0xc93>
f0101cf2:	68 97 46 10 f0       	push   $0xf0104697
f0101cf7:	68 56 44 10 f0       	push   $0xf0104456
f0101cfc:	68 33 03 00 00       	push   $0x333
f0101d01:	68 20 44 10 f0       	push   $0xf0104420
f0101d06:	e8 c9 e3 ff ff       	call   f01000d4 <_panic>
	assert(pp2->pp_ref == 0);
f0101d0b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d10:	74 19                	je     f0101d2b <mem_init+0xcb3>
f0101d12:	68 a8 46 10 f0       	push   $0xf01046a8
f0101d17:	68 56 44 10 f0       	push   $0xf0104456
f0101d1c:	68 34 03 00 00       	push   $0x334
f0101d21:	68 20 44 10 f0       	push   $0xf0104420
f0101d26:	e8 a9 e3 ff ff       	call   f01000d4 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d2b:	83 ec 0c             	sub    $0xc,%esp
f0101d2e:	6a 00                	push   $0x0
f0101d30:	e8 af f0 ff ff       	call   f0100de4 <page_alloc>
f0101d35:	83 c4 10             	add    $0x10,%esp
f0101d38:	85 c0                	test   %eax,%eax
f0101d3a:	74 04                	je     f0101d40 <mem_init+0xcc8>
f0101d3c:	39 c3                	cmp    %eax,%ebx
f0101d3e:	74 19                	je     f0101d59 <mem_init+0xce1>
f0101d40:	68 f8 41 10 f0       	push   $0xf01041f8
f0101d45:	68 56 44 10 f0       	push   $0xf0104456
f0101d4a:	68 37 03 00 00       	push   $0x337
f0101d4f:	68 20 44 10 f0       	push   $0xf0104420
f0101d54:	e8 7b e3 ff ff       	call   f01000d4 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d59:	83 ec 08             	sub    $0x8,%esp
f0101d5c:	6a 00                	push   $0x0
f0101d5e:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101d64:	e8 67 f2 ff ff       	call   f0100fd0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d69:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101d6f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d74:	89 f8                	mov    %edi,%eax
f0101d76:	e8 57 ec ff ff       	call   f01009d2 <check_va2pa>
f0101d7b:	83 c4 10             	add    $0x10,%esp
f0101d7e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d81:	74 19                	je     f0101d9c <mem_init+0xd24>
f0101d83:	68 1c 42 10 f0       	push   $0xf010421c
f0101d88:	68 56 44 10 f0       	push   $0xf0104456
f0101d8d:	68 3b 03 00 00       	push   $0x33b
f0101d92:	68 20 44 10 f0       	push   $0xf0104420
f0101d97:	e8 38 e3 ff ff       	call   f01000d4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d9c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da1:	89 f8                	mov    %edi,%eax
f0101da3:	e8 2a ec ff ff       	call   f01009d2 <check_va2pa>
f0101da8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101dab:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101db1:	c1 fa 03             	sar    $0x3,%edx
f0101db4:	c1 e2 0c             	shl    $0xc,%edx
f0101db7:	39 d0                	cmp    %edx,%eax
f0101db9:	74 19                	je     f0101dd4 <mem_init+0xd5c>
f0101dbb:	68 c8 41 10 f0       	push   $0xf01041c8
f0101dc0:	68 56 44 10 f0       	push   $0xf0104456
f0101dc5:	68 3c 03 00 00       	push   $0x33c
f0101dca:	68 20 44 10 f0       	push   $0xf0104420
f0101dcf:	e8 00 e3 ff ff       	call   f01000d4 <_panic>
	assert(pp1->pp_ref == 1);
f0101dd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dd7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ddc:	74 19                	je     f0101df7 <mem_init+0xd7f>
f0101dde:	68 4e 46 10 f0       	push   $0xf010464e
f0101de3:	68 56 44 10 f0       	push   $0xf0104456
f0101de8:	68 3d 03 00 00       	push   $0x33d
f0101ded:	68 20 44 10 f0       	push   $0xf0104420
f0101df2:	e8 dd e2 ff ff       	call   f01000d4 <_panic>
	assert(pp2->pp_ref == 0);
f0101df7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dfc:	74 19                	je     f0101e17 <mem_init+0xd9f>
f0101dfe:	68 a8 46 10 f0       	push   $0xf01046a8
f0101e03:	68 56 44 10 f0       	push   $0xf0104456
f0101e08:	68 3e 03 00 00       	push   $0x33e
f0101e0d:	68 20 44 10 f0       	push   $0xf0104420
f0101e12:	e8 bd e2 ff ff       	call   f01000d4 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e17:	83 ec 08             	sub    $0x8,%esp
f0101e1a:	68 00 10 00 00       	push   $0x1000
f0101e1f:	57                   	push   %edi
f0101e20:	e8 ab f1 ff ff       	call   f0100fd0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e25:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101e2b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e30:	89 f8                	mov    %edi,%eax
f0101e32:	e8 9b eb ff ff       	call   f01009d2 <check_va2pa>
f0101e37:	83 c4 10             	add    $0x10,%esp
f0101e3a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e3d:	74 19                	je     f0101e58 <mem_init+0xde0>
f0101e3f:	68 1c 42 10 f0       	push   $0xf010421c
f0101e44:	68 56 44 10 f0       	push   $0xf0104456
f0101e49:	68 42 03 00 00       	push   $0x342
f0101e4e:	68 20 44 10 f0       	push   $0xf0104420
f0101e53:	e8 7c e2 ff ff       	call   f01000d4 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e58:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e5d:	89 f8                	mov    %edi,%eax
f0101e5f:	e8 6e eb ff ff       	call   f01009d2 <check_va2pa>
f0101e64:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e67:	74 19                	je     f0101e82 <mem_init+0xe0a>
f0101e69:	68 40 42 10 f0       	push   $0xf0104240
f0101e6e:	68 56 44 10 f0       	push   $0xf0104456
f0101e73:	68 43 03 00 00       	push   $0x343
f0101e78:	68 20 44 10 f0       	push   $0xf0104420
f0101e7d:	e8 52 e2 ff ff       	call   f01000d4 <_panic>
	assert(pp1->pp_ref == 0);
f0101e82:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e85:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e8a:	74 19                	je     f0101ea5 <mem_init+0xe2d>
f0101e8c:	68 b9 46 10 f0       	push   $0xf01046b9
f0101e91:	68 56 44 10 f0       	push   $0xf0104456
f0101e96:	68 44 03 00 00       	push   $0x344
f0101e9b:	68 20 44 10 f0       	push   $0xf0104420
f0101ea0:	e8 2f e2 ff ff       	call   f01000d4 <_panic>
	assert(pp2->pp_ref == 0);
f0101ea5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101eaa:	74 19                	je     f0101ec5 <mem_init+0xe4d>
f0101eac:	68 a8 46 10 f0       	push   $0xf01046a8
f0101eb1:	68 56 44 10 f0       	push   $0xf0104456
f0101eb6:	68 45 03 00 00       	push   $0x345
f0101ebb:	68 20 44 10 f0       	push   $0xf0104420
f0101ec0:	e8 0f e2 ff ff       	call   f01000d4 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ec5:	83 ec 0c             	sub    $0xc,%esp
f0101ec8:	6a 00                	push   $0x0
f0101eca:	e8 15 ef ff ff       	call   f0100de4 <page_alloc>
f0101ecf:	83 c4 10             	add    $0x10,%esp
f0101ed2:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ed5:	75 04                	jne    f0101edb <mem_init+0xe63>
f0101ed7:	85 c0                	test   %eax,%eax
f0101ed9:	75 19                	jne    f0101ef4 <mem_init+0xe7c>
f0101edb:	68 68 42 10 f0       	push   $0xf0104268
f0101ee0:	68 56 44 10 f0       	push   $0xf0104456
f0101ee5:	68 48 03 00 00       	push   $0x348
f0101eea:	68 20 44 10 f0       	push   $0xf0104420
f0101eef:	e8 e0 e1 ff ff       	call   f01000d4 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ef4:	83 ec 0c             	sub    $0xc,%esp
f0101ef7:	6a 00                	push   $0x0
f0101ef9:	e8 e6 ee ff ff       	call   f0100de4 <page_alloc>
f0101efe:	83 c4 10             	add    $0x10,%esp
f0101f01:	85 c0                	test   %eax,%eax
f0101f03:	74 19                	je     f0101f1e <mem_init+0xea6>
f0101f05:	68 fc 45 10 f0       	push   $0xf01045fc
f0101f0a:	68 56 44 10 f0       	push   $0xf0104456
f0101f0f:	68 4b 03 00 00       	push   $0x34b
f0101f14:	68 20 44 10 f0       	push   $0xf0104420
f0101f19:	e8 b6 e1 ff ff       	call   f01000d4 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f1e:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0101f24:	8b 11                	mov    (%ecx),%edx
f0101f26:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f2c:	89 f0                	mov    %esi,%eax
f0101f2e:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101f34:	c1 f8 03             	sar    $0x3,%eax
f0101f37:	c1 e0 0c             	shl    $0xc,%eax
f0101f3a:	39 c2                	cmp    %eax,%edx
f0101f3c:	74 19                	je     f0101f57 <mem_init+0xedf>
f0101f3e:	68 44 3f 10 f0       	push   $0xf0103f44
f0101f43:	68 56 44 10 f0       	push   $0xf0104456
f0101f48:	68 4e 03 00 00       	push   $0x34e
f0101f4d:	68 20 44 10 f0       	push   $0xf0104420
f0101f52:	e8 7d e1 ff ff       	call   f01000d4 <_panic>
	kern_pgdir[0] = 0;
f0101f57:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f5d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f62:	74 19                	je     f0101f7d <mem_init+0xf05>
f0101f64:	68 5f 46 10 f0       	push   $0xf010465f
f0101f69:	68 56 44 10 f0       	push   $0xf0104456
f0101f6e:	68 50 03 00 00       	push   $0x350
f0101f73:	68 20 44 10 f0       	push   $0xf0104420
f0101f78:	e8 57 e1 ff ff       	call   f01000d4 <_panic>
	pp0->pp_ref = 0;
f0101f7d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f83:	83 ec 0c             	sub    $0xc,%esp
f0101f86:	56                   	push   %esi
f0101f87:	e8 e8 ee ff ff       	call   f0100e74 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f8c:	83 c4 0c             	add    $0xc,%esp
f0101f8f:	6a 01                	push   $0x1
f0101f91:	68 00 10 40 00       	push   $0x401000
f0101f96:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101f9c:	e8 32 ef ff ff       	call   f0100ed3 <pgdir_walk>
f0101fa1:	89 c7                	mov    %eax,%edi
f0101fa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101fa6:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101fab:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fae:	8b 40 04             	mov    0x4(%eax),%eax
f0101fb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fb6:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f0101fbc:	89 c2                	mov    %eax,%edx
f0101fbe:	c1 ea 0c             	shr    $0xc,%edx
f0101fc1:	83 c4 10             	add    $0x10,%esp
f0101fc4:	39 ca                	cmp    %ecx,%edx
f0101fc6:	72 15                	jb     f0101fdd <mem_init+0xf65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fc8:	50                   	push   %eax
f0101fc9:	68 10 3c 10 f0       	push   $0xf0103c10
f0101fce:	68 57 03 00 00       	push   $0x357
f0101fd3:	68 20 44 10 f0       	push   $0xf0104420
f0101fd8:	e8 f7 e0 ff ff       	call   f01000d4 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101fdd:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101fe2:	39 c7                	cmp    %eax,%edi
f0101fe4:	74 19                	je     f0101fff <mem_init+0xf87>
f0101fe6:	68 ca 46 10 f0       	push   $0xf01046ca
f0101feb:	68 56 44 10 f0       	push   $0xf0104456
f0101ff0:	68 58 03 00 00       	push   $0x358
f0101ff5:	68 20 44 10 f0       	push   $0xf0104420
f0101ffa:	e8 d5 e0 ff ff       	call   f01000d4 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101fff:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102002:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102009:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010200f:	89 f0                	mov    %esi,%eax
f0102011:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102017:	c1 f8 03             	sar    $0x3,%eax
f010201a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010201d:	89 c2                	mov    %eax,%edx
f010201f:	c1 ea 0c             	shr    $0xc,%edx
f0102022:	39 d1                	cmp    %edx,%ecx
f0102024:	77 12                	ja     f0102038 <mem_init+0xfc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102026:	50                   	push   %eax
f0102027:	68 10 3c 10 f0       	push   $0xf0103c10
f010202c:	6a 52                	push   $0x52
f010202e:	68 34 44 10 f0       	push   $0xf0104434
f0102033:	e8 9c e0 ff ff       	call   f01000d4 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102038:	83 ec 04             	sub    $0x4,%esp
f010203b:	68 00 10 00 00       	push   $0x1000
f0102040:	68 ff 00 00 00       	push   $0xff
f0102045:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010204a:	50                   	push   %eax
f010204b:	e8 49 11 00 00       	call   f0103199 <memset>
	page_free(pp0);
f0102050:	89 34 24             	mov    %esi,(%esp)
f0102053:	e8 1c ee ff ff       	call   f0100e74 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102058:	83 c4 0c             	add    $0xc,%esp
f010205b:	6a 01                	push   $0x1
f010205d:	6a 00                	push   $0x0
f010205f:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0102065:	e8 69 ee ff ff       	call   f0100ed3 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010206a:	89 f2                	mov    %esi,%edx
f010206c:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102072:	c1 fa 03             	sar    $0x3,%edx
f0102075:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102078:	89 d0                	mov    %edx,%eax
f010207a:	c1 e8 0c             	shr    $0xc,%eax
f010207d:	83 c4 10             	add    $0x10,%esp
f0102080:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0102086:	72 12                	jb     f010209a <mem_init+0x1022>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102088:	52                   	push   %edx
f0102089:	68 10 3c 10 f0       	push   $0xf0103c10
f010208e:	6a 52                	push   $0x52
f0102090:	68 34 44 10 f0       	push   $0xf0104434
f0102095:	e8 3a e0 ff ff       	call   f01000d4 <_panic>
	return (void *)(pa + KERNBASE);
f010209a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01020a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020a3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020a9:	f6 00 01             	testb  $0x1,(%eax)
f01020ac:	74 19                	je     f01020c7 <mem_init+0x104f>
f01020ae:	68 e2 46 10 f0       	push   $0xf01046e2
f01020b3:	68 56 44 10 f0       	push   $0xf0104456
f01020b8:	68 62 03 00 00       	push   $0x362
f01020bd:	68 20 44 10 f0       	push   $0xf0104420
f01020c2:	e8 0d e0 ff ff       	call   f01000d4 <_panic>
f01020c7:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01020ca:	39 d0                	cmp    %edx,%eax
f01020cc:	75 db                	jne    f01020a9 <mem_init+0x1031>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01020ce:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01020d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01020d9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01020df:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01020e2:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01020e7:	83 ec 0c             	sub    $0xc,%esp
f01020ea:	56                   	push   %esi
f01020eb:	e8 84 ed ff ff       	call   f0100e74 <page_free>
	page_free(pp1);
f01020f0:	83 c4 04             	add    $0x4,%esp
f01020f3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020f6:	e8 79 ed ff ff       	call   f0100e74 <page_free>
	page_free(pp2);
f01020fb:	89 1c 24             	mov    %ebx,(%esp)
f01020fe:	e8 71 ed ff ff       	call   f0100e74 <page_free>

	cprintf("check_page() succeeded!\n");
f0102103:	c7 04 24 f9 46 10 f0 	movl   $0xf01046f9,(%esp)
f010210a:	e8 d1 05 00 00       	call   f01026e0 <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010210f:	8b 35 68 79 11 f0    	mov    0xf0117968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102115:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f010211a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010211d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102124:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102129:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010212c:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102132:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102135:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102138:	bb 00 00 00 00       	mov    $0x0,%ebx
f010213d:	eb 55                	jmp    f0102194 <mem_init+0x111c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010213f:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102145:	89 f0                	mov    %esi,%eax
f0102147:	e8 86 e8 ff ff       	call   f01009d2 <check_va2pa>
f010214c:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102153:	77 15                	ja     f010216a <mem_init+0x10f2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102155:	57                   	push   %edi
f0102156:	68 a8 3d 10 f0       	push   $0xf0103da8
f010215b:	68 a9 02 00 00       	push   $0x2a9
f0102160:	68 20 44 10 f0       	push   $0xf0104420
f0102165:	e8 6a df ff ff       	call   f01000d4 <_panic>
f010216a:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f0102171:	39 d0                	cmp    %edx,%eax
f0102173:	74 19                	je     f010218e <mem_init+0x1116>
f0102175:	68 8c 42 10 f0       	push   $0xf010428c
f010217a:	68 56 44 10 f0       	push   $0xf0104456
f010217f:	68 a9 02 00 00       	push   $0x2a9
f0102184:	68 20 44 10 f0       	push   $0xf0104420
f0102189:	e8 46 df ff ff       	call   f01000d4 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010218e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102194:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102197:	77 a6                	ja     f010213f <mem_init+0x10c7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102199:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010219c:	c1 e7 0c             	shl    $0xc,%edi
f010219f:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021a4:	eb 30                	jmp    f01021d6 <mem_init+0x115e>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01021a6:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01021ac:	89 f0                	mov    %esi,%eax
f01021ae:	e8 1f e8 ff ff       	call   f01009d2 <check_va2pa>
f01021b3:	39 c3                	cmp    %eax,%ebx
f01021b5:	74 19                	je     f01021d0 <mem_init+0x1158>
f01021b7:	68 c0 42 10 f0       	push   $0xf01042c0
f01021bc:	68 56 44 10 f0       	push   $0xf0104456
f01021c1:	68 ae 02 00 00       	push   $0x2ae
f01021c6:	68 20 44 10 f0       	push   $0xf0104420
f01021cb:	e8 04 df ff ff       	call   f01000d4 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01021d0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021d6:	39 fb                	cmp    %edi,%ebx
f01021d8:	72 cc                	jb     f01021a6 <mem_init+0x112e>
f01021da:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021df:	bf 00 d0 10 f0       	mov    $0xf010d000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01021e4:	89 da                	mov    %ebx,%edx
f01021e6:	89 f0                	mov    %esi,%eax
f01021e8:	e8 e5 e7 ff ff       	call   f01009d2 <check_va2pa>
f01021ed:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01021f3:	77 19                	ja     f010220e <mem_init+0x1196>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021f5:	68 00 d0 10 f0       	push   $0xf010d000
f01021fa:	68 a8 3d 10 f0       	push   $0xf0103da8
f01021ff:	68 b2 02 00 00       	push   $0x2b2
f0102204:	68 20 44 10 f0       	push   $0xf0104420
f0102209:	e8 c6 de ff ff       	call   f01000d4 <_panic>
f010220e:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102214:	39 d0                	cmp    %edx,%eax
f0102216:	74 19                	je     f0102231 <mem_init+0x11b9>
f0102218:	68 e8 42 10 f0       	push   $0xf01042e8
f010221d:	68 56 44 10 f0       	push   $0xf0104456
f0102222:	68 b2 02 00 00       	push   $0x2b2
f0102227:	68 20 44 10 f0       	push   $0xf0104420
f010222c:	e8 a3 de ff ff       	call   f01000d4 <_panic>
f0102231:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102237:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010223d:	75 a5                	jne    f01021e4 <mem_init+0x116c>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010223f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102244:	89 f0                	mov    %esi,%eax
f0102246:	e8 87 e7 ff ff       	call   f01009d2 <check_va2pa>
f010224b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010224e:	74 51                	je     f01022a1 <mem_init+0x1229>
f0102250:	68 30 43 10 f0       	push   $0xf0104330
f0102255:	68 56 44 10 f0       	push   $0xf0104456
f010225a:	68 b3 02 00 00       	push   $0x2b3
f010225f:	68 20 44 10 f0       	push   $0xf0104420
f0102264:	e8 6b de ff ff       	call   f01000d4 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102269:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010226e:	72 36                	jb     f01022a6 <mem_init+0x122e>
f0102270:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102275:	76 07                	jbe    f010227e <mem_init+0x1206>
f0102277:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010227c:	75 28                	jne    f01022a6 <mem_init+0x122e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010227e:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102282:	0f 85 83 00 00 00    	jne    f010230b <mem_init+0x1293>
f0102288:	68 12 47 10 f0       	push   $0xf0104712
f010228d:	68 56 44 10 f0       	push   $0xf0104456
f0102292:	68 bb 02 00 00       	push   $0x2bb
f0102297:	68 20 44 10 f0       	push   $0xf0104420
f010229c:	e8 33 de ff ff       	call   f01000d4 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022a1:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01022a6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01022ab:	76 3f                	jbe    f01022ec <mem_init+0x1274>
				assert(pgdir[i] & PTE_P);
f01022ad:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01022b0:	f6 c2 01             	test   $0x1,%dl
f01022b3:	75 19                	jne    f01022ce <mem_init+0x1256>
f01022b5:	68 12 47 10 f0       	push   $0xf0104712
f01022ba:	68 56 44 10 f0       	push   $0xf0104456
f01022bf:	68 bf 02 00 00       	push   $0x2bf
f01022c4:	68 20 44 10 f0       	push   $0xf0104420
f01022c9:	e8 06 de ff ff       	call   f01000d4 <_panic>
				assert(pgdir[i] & PTE_W);
f01022ce:	f6 c2 02             	test   $0x2,%dl
f01022d1:	75 38                	jne    f010230b <mem_init+0x1293>
f01022d3:	68 23 47 10 f0       	push   $0xf0104723
f01022d8:	68 56 44 10 f0       	push   $0xf0104456
f01022dd:	68 c0 02 00 00       	push   $0x2c0
f01022e2:	68 20 44 10 f0       	push   $0xf0104420
f01022e7:	e8 e8 dd ff ff       	call   f01000d4 <_panic>
			} else
				assert(pgdir[i] == 0);
f01022ec:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01022f0:	74 19                	je     f010230b <mem_init+0x1293>
f01022f2:	68 34 47 10 f0       	push   $0xf0104734
f01022f7:	68 56 44 10 f0       	push   $0xf0104456
f01022fc:	68 c2 02 00 00       	push   $0x2c2
f0102301:	68 20 44 10 f0       	push   $0xf0104420
f0102306:	e8 c9 dd ff ff       	call   f01000d4 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010230b:	83 c0 01             	add    $0x1,%eax
f010230e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102313:	0f 86 50 ff ff ff    	jbe    f0102269 <mem_init+0x11f1>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102319:	83 ec 0c             	sub    $0xc,%esp
f010231c:	68 60 43 10 f0       	push   $0xf0104360
f0102321:	e8 ba 03 00 00       	call   f01026e0 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102326:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010232b:	83 c4 10             	add    $0x10,%esp
f010232e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102333:	77 15                	ja     f010234a <mem_init+0x12d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102335:	50                   	push   %eax
f0102336:	68 a8 3d 10 f0       	push   $0xf0103da8
f010233b:	68 d7 00 00 00       	push   $0xd7
f0102340:	68 20 44 10 f0       	push   $0xf0104420
f0102345:	e8 8a dd ff ff       	call   f01000d4 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010234a:	05 00 00 00 10       	add    $0x10000000,%eax
f010234f:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102352:	b8 00 00 00 00       	mov    $0x0,%eax
f0102357:	e8 da e6 ff ff       	call   f0100a36 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010235c:	0f 20 c0             	mov    %cr0,%eax
f010235f:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102362:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102367:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010236a:	83 ec 0c             	sub    $0xc,%esp
f010236d:	6a 00                	push   $0x0
f010236f:	e8 70 ea ff ff       	call   f0100de4 <page_alloc>
f0102374:	89 c3                	mov    %eax,%ebx
f0102376:	83 c4 10             	add    $0x10,%esp
f0102379:	85 c0                	test   %eax,%eax
f010237b:	75 19                	jne    f0102396 <mem_init+0x131e>
f010237d:	68 51 45 10 f0       	push   $0xf0104551
f0102382:	68 56 44 10 f0       	push   $0xf0104456
f0102387:	68 7d 03 00 00       	push   $0x37d
f010238c:	68 20 44 10 f0       	push   $0xf0104420
f0102391:	e8 3e dd ff ff       	call   f01000d4 <_panic>
	assert((pp1 = page_alloc(0)));
f0102396:	83 ec 0c             	sub    $0xc,%esp
f0102399:	6a 00                	push   $0x0
f010239b:	e8 44 ea ff ff       	call   f0100de4 <page_alloc>
f01023a0:	89 c7                	mov    %eax,%edi
f01023a2:	83 c4 10             	add    $0x10,%esp
f01023a5:	85 c0                	test   %eax,%eax
f01023a7:	75 19                	jne    f01023c2 <mem_init+0x134a>
f01023a9:	68 67 45 10 f0       	push   $0xf0104567
f01023ae:	68 56 44 10 f0       	push   $0xf0104456
f01023b3:	68 7e 03 00 00       	push   $0x37e
f01023b8:	68 20 44 10 f0       	push   $0xf0104420
f01023bd:	e8 12 dd ff ff       	call   f01000d4 <_panic>
	assert((pp2 = page_alloc(0)));
f01023c2:	83 ec 0c             	sub    $0xc,%esp
f01023c5:	6a 00                	push   $0x0
f01023c7:	e8 18 ea ff ff       	call   f0100de4 <page_alloc>
f01023cc:	89 c6                	mov    %eax,%esi
f01023ce:	83 c4 10             	add    $0x10,%esp
f01023d1:	85 c0                	test   %eax,%eax
f01023d3:	75 19                	jne    f01023ee <mem_init+0x1376>
f01023d5:	68 7d 45 10 f0       	push   $0xf010457d
f01023da:	68 56 44 10 f0       	push   $0xf0104456
f01023df:	68 7f 03 00 00       	push   $0x37f
f01023e4:	68 20 44 10 f0       	push   $0xf0104420
f01023e9:	e8 e6 dc ff ff       	call   f01000d4 <_panic>
	page_free(pp0);
f01023ee:	83 ec 0c             	sub    $0xc,%esp
f01023f1:	53                   	push   %ebx
f01023f2:	e8 7d ea ff ff       	call   f0100e74 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023f7:	89 f8                	mov    %edi,%eax
f01023f9:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01023ff:	c1 f8 03             	sar    $0x3,%eax
f0102402:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102405:	89 c2                	mov    %eax,%edx
f0102407:	c1 ea 0c             	shr    $0xc,%edx
f010240a:	83 c4 10             	add    $0x10,%esp
f010240d:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102413:	72 12                	jb     f0102427 <mem_init+0x13af>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102415:	50                   	push   %eax
f0102416:	68 10 3c 10 f0       	push   $0xf0103c10
f010241b:	6a 52                	push   $0x52
f010241d:	68 34 44 10 f0       	push   $0xf0104434
f0102422:	e8 ad dc ff ff       	call   f01000d4 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102427:	83 ec 04             	sub    $0x4,%esp
f010242a:	68 00 10 00 00       	push   $0x1000
f010242f:	6a 01                	push   $0x1
f0102431:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102436:	50                   	push   %eax
f0102437:	e8 5d 0d 00 00       	call   f0103199 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010243c:	89 f0                	mov    %esi,%eax
f010243e:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102444:	c1 f8 03             	sar    $0x3,%eax
f0102447:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010244a:	89 c2                	mov    %eax,%edx
f010244c:	c1 ea 0c             	shr    $0xc,%edx
f010244f:	83 c4 10             	add    $0x10,%esp
f0102452:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102458:	72 12                	jb     f010246c <mem_init+0x13f4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010245a:	50                   	push   %eax
f010245b:	68 10 3c 10 f0       	push   $0xf0103c10
f0102460:	6a 52                	push   $0x52
f0102462:	68 34 44 10 f0       	push   $0xf0104434
f0102467:	e8 68 dc ff ff       	call   f01000d4 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010246c:	83 ec 04             	sub    $0x4,%esp
f010246f:	68 00 10 00 00       	push   $0x1000
f0102474:	6a 02                	push   $0x2
f0102476:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010247b:	50                   	push   %eax
f010247c:	e8 18 0d 00 00       	call   f0103199 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102481:	6a 02                	push   $0x2
f0102483:	68 00 10 00 00       	push   $0x1000
f0102488:	57                   	push   %edi
f0102489:	ff 35 68 79 11 f0    	pushl  0xf0117968
f010248f:	e8 77 eb ff ff       	call   f010100b <page_insert>
	assert(pp1->pp_ref == 1);
f0102494:	83 c4 20             	add    $0x20,%esp
f0102497:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010249c:	74 19                	je     f01024b7 <mem_init+0x143f>
f010249e:	68 4e 46 10 f0       	push   $0xf010464e
f01024a3:	68 56 44 10 f0       	push   $0xf0104456
f01024a8:	68 84 03 00 00       	push   $0x384
f01024ad:	68 20 44 10 f0       	push   $0xf0104420
f01024b2:	e8 1d dc ff ff       	call   f01000d4 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01024b7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01024be:	01 01 01 
f01024c1:	74 19                	je     f01024dc <mem_init+0x1464>
f01024c3:	68 80 43 10 f0       	push   $0xf0104380
f01024c8:	68 56 44 10 f0       	push   $0xf0104456
f01024cd:	68 85 03 00 00       	push   $0x385
f01024d2:	68 20 44 10 f0       	push   $0xf0104420
f01024d7:	e8 f8 db ff ff       	call   f01000d4 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01024dc:	6a 02                	push   $0x2
f01024de:	68 00 10 00 00       	push   $0x1000
f01024e3:	56                   	push   %esi
f01024e4:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01024ea:	e8 1c eb ff ff       	call   f010100b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024ef:	83 c4 10             	add    $0x10,%esp
f01024f2:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01024f9:	02 02 02 
f01024fc:	74 19                	je     f0102517 <mem_init+0x149f>
f01024fe:	68 a4 43 10 f0       	push   $0xf01043a4
f0102503:	68 56 44 10 f0       	push   $0xf0104456
f0102508:	68 87 03 00 00       	push   $0x387
f010250d:	68 20 44 10 f0       	push   $0xf0104420
f0102512:	e8 bd db ff ff       	call   f01000d4 <_panic>
	assert(pp2->pp_ref == 1);
f0102517:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010251c:	74 19                	je     f0102537 <mem_init+0x14bf>
f010251e:	68 70 46 10 f0       	push   $0xf0104670
f0102523:	68 56 44 10 f0       	push   $0xf0104456
f0102528:	68 88 03 00 00       	push   $0x388
f010252d:	68 20 44 10 f0       	push   $0xf0104420
f0102532:	e8 9d db ff ff       	call   f01000d4 <_panic>
	assert(pp1->pp_ref == 0);
f0102537:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010253c:	74 19                	je     f0102557 <mem_init+0x14df>
f010253e:	68 b9 46 10 f0       	push   $0xf01046b9
f0102543:	68 56 44 10 f0       	push   $0xf0104456
f0102548:	68 89 03 00 00       	push   $0x389
f010254d:	68 20 44 10 f0       	push   $0xf0104420
f0102552:	e8 7d db ff ff       	call   f01000d4 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102557:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010255e:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102561:	89 f0                	mov    %esi,%eax
f0102563:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102569:	c1 f8 03             	sar    $0x3,%eax
f010256c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010256f:	89 c2                	mov    %eax,%edx
f0102571:	c1 ea 0c             	shr    $0xc,%edx
f0102574:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f010257a:	72 12                	jb     f010258e <mem_init+0x1516>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010257c:	50                   	push   %eax
f010257d:	68 10 3c 10 f0       	push   $0xf0103c10
f0102582:	6a 52                	push   $0x52
f0102584:	68 34 44 10 f0       	push   $0xf0104434
f0102589:	e8 46 db ff ff       	call   f01000d4 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010258e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102595:	03 03 03 
f0102598:	74 19                	je     f01025b3 <mem_init+0x153b>
f010259a:	68 c8 43 10 f0       	push   $0xf01043c8
f010259f:	68 56 44 10 f0       	push   $0xf0104456
f01025a4:	68 8b 03 00 00       	push   $0x38b
f01025a9:	68 20 44 10 f0       	push   $0xf0104420
f01025ae:	e8 21 db ff ff       	call   f01000d4 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025b3:	83 ec 08             	sub    $0x8,%esp
f01025b6:	68 00 10 00 00       	push   $0x1000
f01025bb:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01025c1:	e8 0a ea ff ff       	call   f0100fd0 <page_remove>
	assert(pp2->pp_ref == 0);
f01025c6:	83 c4 10             	add    $0x10,%esp
f01025c9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025ce:	74 19                	je     f01025e9 <mem_init+0x1571>
f01025d0:	68 a8 46 10 f0       	push   $0xf01046a8
f01025d5:	68 56 44 10 f0       	push   $0xf0104456
f01025da:	68 8d 03 00 00       	push   $0x38d
f01025df:	68 20 44 10 f0       	push   $0xf0104420
f01025e4:	e8 eb da ff ff       	call   f01000d4 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025e9:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f01025ef:	8b 11                	mov    (%ecx),%edx
f01025f1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025f7:	89 d8                	mov    %ebx,%eax
f01025f9:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01025ff:	c1 f8 03             	sar    $0x3,%eax
f0102602:	c1 e0 0c             	shl    $0xc,%eax
f0102605:	39 c2                	cmp    %eax,%edx
f0102607:	74 19                	je     f0102622 <mem_init+0x15aa>
f0102609:	68 44 3f 10 f0       	push   $0xf0103f44
f010260e:	68 56 44 10 f0       	push   $0xf0104456
f0102613:	68 90 03 00 00       	push   $0x390
f0102618:	68 20 44 10 f0       	push   $0xf0104420
f010261d:	e8 b2 da ff ff       	call   f01000d4 <_panic>
	kern_pgdir[0] = 0;
f0102622:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102628:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010262d:	74 19                	je     f0102648 <mem_init+0x15d0>
f010262f:	68 5f 46 10 f0       	push   $0xf010465f
f0102634:	68 56 44 10 f0       	push   $0xf0104456
f0102639:	68 92 03 00 00       	push   $0x392
f010263e:	68 20 44 10 f0       	push   $0xf0104420
f0102643:	e8 8c da ff ff       	call   f01000d4 <_panic>
	pp0->pp_ref = 0;
f0102648:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010264e:	83 ec 0c             	sub    $0xc,%esp
f0102651:	53                   	push   %ebx
f0102652:	e8 1d e8 ff ff       	call   f0100e74 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102657:	c7 04 24 f4 43 10 f0 	movl   $0xf01043f4,(%esp)
f010265e:	e8 7d 00 00 00       	call   f01026e0 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102663:	83 c4 10             	add    $0x10,%esp
f0102666:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102669:	5b                   	pop    %ebx
f010266a:	5e                   	pop    %esi
f010266b:	5f                   	pop    %edi
f010266c:	5d                   	pop    %ebp
f010266d:	c3                   	ret    

f010266e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010266e:	55                   	push   %ebp
f010266f:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102671:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102674:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102677:	5d                   	pop    %ebp
f0102678:	c3                   	ret    

f0102679 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102679:	55                   	push   %ebp
f010267a:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010267c:	ba 70 00 00 00       	mov    $0x70,%edx
f0102681:	8b 45 08             	mov    0x8(%ebp),%eax
f0102684:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102685:	ba 71 00 00 00       	mov    $0x71,%edx
f010268a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010268b:	0f b6 c0             	movzbl %al,%eax
}
f010268e:	5d                   	pop    %ebp
f010268f:	c3                   	ret    

f0102690 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102690:	55                   	push   %ebp
f0102691:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102693:	ba 70 00 00 00       	mov    $0x70,%edx
f0102698:	8b 45 08             	mov    0x8(%ebp),%eax
f010269b:	ee                   	out    %al,(%dx)
f010269c:	ba 71 00 00 00       	mov    $0x71,%edx
f01026a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026a4:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01026a5:	5d                   	pop    %ebp
f01026a6:	c3                   	ret    

f01026a7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01026a7:	55                   	push   %ebp
f01026a8:	89 e5                	mov    %esp,%ebp
f01026aa:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01026ad:	ff 75 08             	pushl  0x8(%ebp)
f01026b0:	e8 86 df ff ff       	call   f010063b <cputchar>
	*cnt++;
}
f01026b5:	83 c4 10             	add    $0x10,%esp
f01026b8:	c9                   	leave  
f01026b9:	c3                   	ret    

f01026ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01026ba:	55                   	push   %ebp
f01026bb:	89 e5                	mov    %esp,%ebp
f01026bd:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01026c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01026c7:	ff 75 0c             	pushl  0xc(%ebp)
f01026ca:	ff 75 08             	pushl  0x8(%ebp)
f01026cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01026d0:	50                   	push   %eax
f01026d1:	68 a7 26 10 f0       	push   $0xf01026a7
f01026d6:	e8 52 04 00 00       	call   f0102b2d <vprintfmt>
	return cnt;
}
f01026db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01026de:	c9                   	leave  
f01026df:	c3                   	ret    

f01026e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01026e0:	55                   	push   %ebp
f01026e1:	89 e5                	mov    %esp,%ebp
f01026e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01026e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01026e9:	50                   	push   %eax
f01026ea:	ff 75 08             	pushl  0x8(%ebp)
f01026ed:	e8 c8 ff ff ff       	call   f01026ba <vcprintf>
	va_end(ap);

	return cnt;
}
f01026f2:	c9                   	leave  
f01026f3:	c3                   	ret    

f01026f4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01026f4:	55                   	push   %ebp
f01026f5:	89 e5                	mov    %esp,%ebp
f01026f7:	57                   	push   %edi
f01026f8:	56                   	push   %esi
f01026f9:	53                   	push   %ebx
f01026fa:	83 ec 14             	sub    $0x14,%esp
f01026fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102700:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102703:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102706:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102709:	8b 1a                	mov    (%edx),%ebx
f010270b:	8b 01                	mov    (%ecx),%eax
f010270d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102710:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102717:	eb 7f                	jmp    f0102798 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0102719:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010271c:	01 d8                	add    %ebx,%eax
f010271e:	89 c6                	mov    %eax,%esi
f0102720:	c1 ee 1f             	shr    $0x1f,%esi
f0102723:	01 c6                	add    %eax,%esi
f0102725:	d1 fe                	sar    %esi
f0102727:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010272a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010272d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102730:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102732:	eb 03                	jmp    f0102737 <stab_binsearch+0x43>
			m--;
f0102734:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102737:	39 c3                	cmp    %eax,%ebx
f0102739:	7f 0d                	jg     f0102748 <stab_binsearch+0x54>
f010273b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010273f:	83 ea 0c             	sub    $0xc,%edx
f0102742:	39 f9                	cmp    %edi,%ecx
f0102744:	75 ee                	jne    f0102734 <stab_binsearch+0x40>
f0102746:	eb 05                	jmp    f010274d <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102748:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010274b:	eb 4b                	jmp    f0102798 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010274d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102750:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102753:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102757:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010275a:	76 11                	jbe    f010276d <stab_binsearch+0x79>
			*region_left = m;
f010275c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010275f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102761:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102764:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010276b:	eb 2b                	jmp    f0102798 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010276d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102770:	73 14                	jae    f0102786 <stab_binsearch+0x92>
			*region_right = m - 1;
f0102772:	83 e8 01             	sub    $0x1,%eax
f0102775:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102778:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010277b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010277d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102784:	eb 12                	jmp    f0102798 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102786:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102789:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010278b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010278f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102791:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102798:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010279b:	0f 8e 78 ff ff ff    	jle    f0102719 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01027a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01027a5:	75 0f                	jne    f01027b6 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01027a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01027aa:	8b 00                	mov    (%eax),%eax
f01027ac:	83 e8 01             	sub    $0x1,%eax
f01027af:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01027b2:	89 06                	mov    %eax,(%esi)
f01027b4:	eb 2c                	jmp    f01027e2 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01027b9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01027bb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01027be:	8b 0e                	mov    (%esi),%ecx
f01027c0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027c3:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01027c6:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027c9:	eb 03                	jmp    f01027ce <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01027cb:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01027ce:	39 c8                	cmp    %ecx,%eax
f01027d0:	7e 0b                	jle    f01027dd <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01027d2:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01027d6:	83 ea 0c             	sub    $0xc,%edx
f01027d9:	39 df                	cmp    %ebx,%edi
f01027db:	75 ee                	jne    f01027cb <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01027dd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01027e0:	89 06                	mov    %eax,(%esi)
	}
}
f01027e2:	83 c4 14             	add    $0x14,%esp
f01027e5:	5b                   	pop    %ebx
f01027e6:	5e                   	pop    %esi
f01027e7:	5f                   	pop    %edi
f01027e8:	5d                   	pop    %ebp
f01027e9:	c3                   	ret    

f01027ea <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01027ea:	55                   	push   %ebp
f01027eb:	89 e5                	mov    %esp,%ebp
f01027ed:	57                   	push   %edi
f01027ee:	56                   	push   %esi
f01027ef:	53                   	push   %ebx
f01027f0:	83 ec 3c             	sub    $0x3c,%esp
f01027f3:	8b 75 08             	mov    0x8(%ebp),%esi
f01027f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01027f9:	c7 03 42 47 10 f0    	movl   $0xf0104742,(%ebx)
	info->eip_line = 0;
f01027ff:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102806:	c7 43 08 42 47 10 f0 	movl   $0xf0104742,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010280d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102814:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102817:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010281e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102824:	76 11                	jbe    f0102837 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102826:	b8 86 c0 10 f0       	mov    $0xf010c086,%eax
f010282b:	3d 59 a2 10 f0       	cmp    $0xf010a259,%eax
f0102830:	77 19                	ja     f010284b <debuginfo_eip+0x61>
f0102832:	e9 aa 01 00 00       	jmp    f01029e1 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102837:	83 ec 04             	sub    $0x4,%esp
f010283a:	68 4c 47 10 f0       	push   $0xf010474c
f010283f:	6a 7f                	push   $0x7f
f0102841:	68 59 47 10 f0       	push   $0xf0104759
f0102846:	e8 89 d8 ff ff       	call   f01000d4 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010284b:	80 3d 85 c0 10 f0 00 	cmpb   $0x0,0xf010c085
f0102852:	0f 85 90 01 00 00    	jne    f01029e8 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102858:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010285f:	b8 58 a2 10 f0       	mov    $0xf010a258,%eax
f0102864:	2d 90 49 10 f0       	sub    $0xf0104990,%eax
f0102869:	c1 f8 02             	sar    $0x2,%eax
f010286c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102872:	83 e8 01             	sub    $0x1,%eax
f0102875:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102878:	83 ec 08             	sub    $0x8,%esp
f010287b:	56                   	push   %esi
f010287c:	6a 64                	push   $0x64
f010287e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102881:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102884:	b8 90 49 10 f0       	mov    $0xf0104990,%eax
f0102889:	e8 66 fe ff ff       	call   f01026f4 <stab_binsearch>
	if (lfile == 0)
f010288e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102891:	83 c4 10             	add    $0x10,%esp
f0102894:	85 c0                	test   %eax,%eax
f0102896:	0f 84 53 01 00 00    	je     f01029ef <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010289c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010289f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01028a5:	83 ec 08             	sub    $0x8,%esp
f01028a8:	56                   	push   %esi
f01028a9:	6a 24                	push   $0x24
f01028ab:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01028ae:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01028b1:	b8 90 49 10 f0       	mov    $0xf0104990,%eax
f01028b6:	e8 39 fe ff ff       	call   f01026f4 <stab_binsearch>

	if (lfun <= rfun) {
f01028bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01028be:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01028c1:	83 c4 10             	add    $0x10,%esp
f01028c4:	39 d0                	cmp    %edx,%eax
f01028c6:	7f 40                	jg     f0102908 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01028c8:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01028cb:	c1 e1 02             	shl    $0x2,%ecx
f01028ce:	8d b9 90 49 10 f0    	lea    -0xfefb670(%ecx),%edi
f01028d4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01028d7:	8b b9 90 49 10 f0    	mov    -0xfefb670(%ecx),%edi
f01028dd:	b9 86 c0 10 f0       	mov    $0xf010c086,%ecx
f01028e2:	81 e9 59 a2 10 f0    	sub    $0xf010a259,%ecx
f01028e8:	39 cf                	cmp    %ecx,%edi
f01028ea:	73 09                	jae    f01028f5 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01028ec:	81 c7 59 a2 10 f0    	add    $0xf010a259,%edi
f01028f2:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01028f5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01028f8:	8b 4f 08             	mov    0x8(%edi),%ecx
f01028fb:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01028fe:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102900:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102903:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102906:	eb 0f                	jmp    f0102917 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102908:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010290b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010290e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102911:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102914:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102917:	83 ec 08             	sub    $0x8,%esp
f010291a:	6a 3a                	push   $0x3a
f010291c:	ff 73 08             	pushl  0x8(%ebx)
f010291f:	e8 59 08 00 00       	call   f010317d <strfind>
f0102924:	2b 43 08             	sub    0x8(%ebx),%eax
f0102927:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010292a:	83 c4 08             	add    $0x8,%esp
f010292d:	56                   	push   %esi
f010292e:	6a 44                	push   $0x44
f0102930:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102933:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102936:	b8 90 49 10 f0       	mov    $0xf0104990,%eax
f010293b:	e8 b4 fd ff ff       	call   f01026f4 <stab_binsearch>
	if ( lline <= rline ){
f0102940:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102943:	83 c4 10             	add    $0x10,%esp
f0102946:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0102949:	0f 8f a7 00 00 00    	jg     f01029f6 <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f010294f:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102952:	8d 04 85 90 49 10 f0 	lea    -0xfefb670(,%eax,4),%eax
f0102959:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f010295d:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102960:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102963:	eb 06                	jmp    f010296b <debuginfo_eip+0x181>
f0102965:	83 ea 01             	sub    $0x1,%edx
f0102968:	83 e8 0c             	sub    $0xc,%eax
f010296b:	39 d6                	cmp    %edx,%esi
f010296d:	7f 34                	jg     f01029a3 <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f010296f:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102973:	80 f9 84             	cmp    $0x84,%cl
f0102976:	74 0b                	je     f0102983 <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102978:	80 f9 64             	cmp    $0x64,%cl
f010297b:	75 e8                	jne    f0102965 <debuginfo_eip+0x17b>
f010297d:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102981:	74 e2                	je     f0102965 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102983:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102986:	8b 14 85 90 49 10 f0 	mov    -0xfefb670(,%eax,4),%edx
f010298d:	b8 86 c0 10 f0       	mov    $0xf010c086,%eax
f0102992:	2d 59 a2 10 f0       	sub    $0xf010a259,%eax
f0102997:	39 c2                	cmp    %eax,%edx
f0102999:	73 08                	jae    f01029a3 <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010299b:	81 c2 59 a2 10 f0    	add    $0xf010a259,%edx
f01029a1:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01029a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01029a6:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029a9:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01029ae:	39 f2                	cmp    %esi,%edx
f01029b0:	7d 50                	jge    f0102a02 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f01029b2:	83 c2 01             	add    $0x1,%edx
f01029b5:	89 d0                	mov    %edx,%eax
f01029b7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01029ba:	8d 14 95 90 49 10 f0 	lea    -0xfefb670(,%edx,4),%edx
f01029c1:	eb 04                	jmp    f01029c7 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01029c3:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01029c7:	39 c6                	cmp    %eax,%esi
f01029c9:	7e 32                	jle    f01029fd <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01029cb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01029cf:	83 c0 01             	add    $0x1,%eax
f01029d2:	83 c2 0c             	add    $0xc,%edx
f01029d5:	80 f9 a0             	cmp    $0xa0,%cl
f01029d8:	74 e9                	je     f01029c3 <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029da:	b8 00 00 00 00       	mov    $0x0,%eax
f01029df:	eb 21                	jmp    f0102a02 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01029e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029e6:	eb 1a                	jmp    f0102a02 <debuginfo_eip+0x218>
f01029e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029ed:	eb 13                	jmp    f0102a02 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01029ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029f4:	eb 0c                	jmp    f0102a02 <debuginfo_eip+0x218>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if ( lline <= rline ){
		info->eip_line = stabs[lline].n_desc;
	}
	else{
		return -1;
f01029f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029fb:	eb 05                	jmp    f0102a02 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a05:	5b                   	pop    %ebx
f0102a06:	5e                   	pop    %esi
f0102a07:	5f                   	pop    %edi
f0102a08:	5d                   	pop    %ebp
f0102a09:	c3                   	ret    

f0102a0a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102a0a:	55                   	push   %ebp
f0102a0b:	89 e5                	mov    %esp,%ebp
f0102a0d:	57                   	push   %edi
f0102a0e:	56                   	push   %esi
f0102a0f:	53                   	push   %ebx
f0102a10:	83 ec 1c             	sub    $0x1c,%esp
f0102a13:	89 c7                	mov    %eax,%edi
f0102a15:	89 d6                	mov    %edx,%esi
f0102a17:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102a1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102a20:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102a26:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a2b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102a2e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102a31:	39 d3                	cmp    %edx,%ebx
f0102a33:	72 05                	jb     f0102a3a <printnum+0x30>
f0102a35:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102a38:	77 45                	ja     f0102a7f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102a3a:	83 ec 0c             	sub    $0xc,%esp
f0102a3d:	ff 75 18             	pushl  0x18(%ebp)
f0102a40:	8b 45 14             	mov    0x14(%ebp),%eax
f0102a43:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102a46:	53                   	push   %ebx
f0102a47:	ff 75 10             	pushl  0x10(%ebp)
f0102a4a:	83 ec 08             	sub    $0x8,%esp
f0102a4d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a50:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a53:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a56:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a59:	e8 42 09 00 00       	call   f01033a0 <__udivdi3>
f0102a5e:	83 c4 18             	add    $0x18,%esp
f0102a61:	52                   	push   %edx
f0102a62:	50                   	push   %eax
f0102a63:	89 f2                	mov    %esi,%edx
f0102a65:	89 f8                	mov    %edi,%eax
f0102a67:	e8 9e ff ff ff       	call   f0102a0a <printnum>
f0102a6c:	83 c4 20             	add    $0x20,%esp
f0102a6f:	eb 18                	jmp    f0102a89 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102a71:	83 ec 08             	sub    $0x8,%esp
f0102a74:	56                   	push   %esi
f0102a75:	ff 75 18             	pushl  0x18(%ebp)
f0102a78:	ff d7                	call   *%edi
f0102a7a:	83 c4 10             	add    $0x10,%esp
f0102a7d:	eb 03                	jmp    f0102a82 <printnum+0x78>
f0102a7f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102a82:	83 eb 01             	sub    $0x1,%ebx
f0102a85:	85 db                	test   %ebx,%ebx
f0102a87:	7f e8                	jg     f0102a71 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102a89:	83 ec 08             	sub    $0x8,%esp
f0102a8c:	56                   	push   %esi
f0102a8d:	83 ec 04             	sub    $0x4,%esp
f0102a90:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a93:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a96:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a99:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a9c:	e8 2f 0a 00 00       	call   f01034d0 <__umoddi3>
f0102aa1:	83 c4 14             	add    $0x14,%esp
f0102aa4:	0f be 80 67 47 10 f0 	movsbl -0xfefb899(%eax),%eax
f0102aab:	50                   	push   %eax
f0102aac:	ff d7                	call   *%edi
}
f0102aae:	83 c4 10             	add    $0x10,%esp
f0102ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ab4:	5b                   	pop    %ebx
f0102ab5:	5e                   	pop    %esi
f0102ab6:	5f                   	pop    %edi
f0102ab7:	5d                   	pop    %ebp
f0102ab8:	c3                   	ret    

f0102ab9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102ab9:	55                   	push   %ebp
f0102aba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102abc:	83 fa 01             	cmp    $0x1,%edx
f0102abf:	7e 0e                	jle    f0102acf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102ac1:	8b 10                	mov    (%eax),%edx
f0102ac3:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102ac6:	89 08                	mov    %ecx,(%eax)
f0102ac8:	8b 02                	mov    (%edx),%eax
f0102aca:	8b 52 04             	mov    0x4(%edx),%edx
f0102acd:	eb 22                	jmp    f0102af1 <getuint+0x38>
	else if (lflag)
f0102acf:	85 d2                	test   %edx,%edx
f0102ad1:	74 10                	je     f0102ae3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102ad3:	8b 10                	mov    (%eax),%edx
f0102ad5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ad8:	89 08                	mov    %ecx,(%eax)
f0102ada:	8b 02                	mov    (%edx),%eax
f0102adc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ae1:	eb 0e                	jmp    f0102af1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102ae3:	8b 10                	mov    (%eax),%edx
f0102ae5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ae8:	89 08                	mov    %ecx,(%eax)
f0102aea:	8b 02                	mov    (%edx),%eax
f0102aec:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102af1:	5d                   	pop    %ebp
f0102af2:	c3                   	ret    

f0102af3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102af3:	55                   	push   %ebp
f0102af4:	89 e5                	mov    %esp,%ebp
f0102af6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102af9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102afd:	8b 10                	mov    (%eax),%edx
f0102aff:	3b 50 04             	cmp    0x4(%eax),%edx
f0102b02:	73 0a                	jae    f0102b0e <sprintputch+0x1b>
		*b->buf++ = ch;
f0102b04:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102b07:	89 08                	mov    %ecx,(%eax)
f0102b09:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b0c:	88 02                	mov    %al,(%edx)
}
f0102b0e:	5d                   	pop    %ebp
f0102b0f:	c3                   	ret    

f0102b10 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102b10:	55                   	push   %ebp
f0102b11:	89 e5                	mov    %esp,%ebp
f0102b13:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b16:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b19:	50                   	push   %eax
f0102b1a:	ff 75 10             	pushl  0x10(%ebp)
f0102b1d:	ff 75 0c             	pushl  0xc(%ebp)
f0102b20:	ff 75 08             	pushl  0x8(%ebp)
f0102b23:	e8 05 00 00 00       	call   f0102b2d <vprintfmt>
	va_end(ap);
}
f0102b28:	83 c4 10             	add    $0x10,%esp
f0102b2b:	c9                   	leave  
f0102b2c:	c3                   	ret    

f0102b2d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102b2d:	55                   	push   %ebp
f0102b2e:	89 e5                	mov    %esp,%ebp
f0102b30:	57                   	push   %edi
f0102b31:	56                   	push   %esi
f0102b32:	53                   	push   %ebx
f0102b33:	83 ec 2c             	sub    $0x2c,%esp
f0102b36:	8b 75 08             	mov    0x8(%ebp),%esi
f0102b39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102b3c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102b3f:	eb 12                	jmp    f0102b53 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102b41:	85 c0                	test   %eax,%eax
f0102b43:	0f 84 89 03 00 00    	je     f0102ed2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102b49:	83 ec 08             	sub    $0x8,%esp
f0102b4c:	53                   	push   %ebx
f0102b4d:	50                   	push   %eax
f0102b4e:	ff d6                	call   *%esi
f0102b50:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102b53:	83 c7 01             	add    $0x1,%edi
f0102b56:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102b5a:	83 f8 25             	cmp    $0x25,%eax
f0102b5d:	75 e2                	jne    f0102b41 <vprintfmt+0x14>
f0102b5f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102b63:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102b6a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102b71:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102b78:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b7d:	eb 07                	jmp    f0102b86 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102b82:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b86:	8d 47 01             	lea    0x1(%edi),%eax
f0102b89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102b8c:	0f b6 07             	movzbl (%edi),%eax
f0102b8f:	0f b6 c8             	movzbl %al,%ecx
f0102b92:	83 e8 23             	sub    $0x23,%eax
f0102b95:	3c 55                	cmp    $0x55,%al
f0102b97:	0f 87 1a 03 00 00    	ja     f0102eb7 <vprintfmt+0x38a>
f0102b9d:	0f b6 c0             	movzbl %al,%eax
f0102ba0:	ff 24 85 00 48 10 f0 	jmp    *-0xfefb800(,%eax,4)
f0102ba7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102baa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102bae:	eb d6                	jmp    f0102b86 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102bb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bb8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102bbb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102bbe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102bc2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102bc5:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102bc8:	83 fa 09             	cmp    $0x9,%edx
f0102bcb:	77 39                	ja     f0102c06 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102bcd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102bd0:	eb e9                	jmp    f0102bbb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102bd2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bd5:	8d 48 04             	lea    0x4(%eax),%ecx
f0102bd8:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102bdb:	8b 00                	mov    (%eax),%eax
f0102bdd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102be0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102be3:	eb 27                	jmp    f0102c0c <vprintfmt+0xdf>
f0102be5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102be8:	85 c0                	test   %eax,%eax
f0102bea:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102bef:	0f 49 c8             	cmovns %eax,%ecx
f0102bf2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bf5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102bf8:	eb 8c                	jmp    f0102b86 <vprintfmt+0x59>
f0102bfa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102bfd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102c04:	eb 80                	jmp    f0102b86 <vprintfmt+0x59>
f0102c06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102c09:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102c0c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c10:	0f 89 70 ff ff ff    	jns    f0102b86 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102c16:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102c1c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c23:	e9 5e ff ff ff       	jmp    f0102b86 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102c28:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102c2e:	e9 53 ff ff ff       	jmp    f0102b86 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102c33:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c36:	8d 50 04             	lea    0x4(%eax),%edx
f0102c39:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c3c:	83 ec 08             	sub    $0x8,%esp
f0102c3f:	53                   	push   %ebx
f0102c40:	ff 30                	pushl  (%eax)
f0102c42:	ff d6                	call   *%esi
			break;
f0102c44:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102c4a:	e9 04 ff ff ff       	jmp    f0102b53 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102c4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c52:	8d 50 04             	lea    0x4(%eax),%edx
f0102c55:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c58:	8b 00                	mov    (%eax),%eax
f0102c5a:	99                   	cltd   
f0102c5b:	31 d0                	xor    %edx,%eax
f0102c5d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102c5f:	83 f8 07             	cmp    $0x7,%eax
f0102c62:	7f 0b                	jg     f0102c6f <vprintfmt+0x142>
f0102c64:	8b 14 85 60 49 10 f0 	mov    -0xfefb6a0(,%eax,4),%edx
f0102c6b:	85 d2                	test   %edx,%edx
f0102c6d:	75 18                	jne    f0102c87 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102c6f:	50                   	push   %eax
f0102c70:	68 7f 47 10 f0       	push   $0xf010477f
f0102c75:	53                   	push   %ebx
f0102c76:	56                   	push   %esi
f0102c77:	e8 94 fe ff ff       	call   f0102b10 <printfmt>
f0102c7c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102c82:	e9 cc fe ff ff       	jmp    f0102b53 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102c87:	52                   	push   %edx
f0102c88:	68 68 44 10 f0       	push   $0xf0104468
f0102c8d:	53                   	push   %ebx
f0102c8e:	56                   	push   %esi
f0102c8f:	e8 7c fe ff ff       	call   f0102b10 <printfmt>
f0102c94:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c9a:	e9 b4 fe ff ff       	jmp    f0102b53 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102c9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ca2:	8d 50 04             	lea    0x4(%eax),%edx
f0102ca5:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ca8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102caa:	85 ff                	test   %edi,%edi
f0102cac:	b8 78 47 10 f0       	mov    $0xf0104778,%eax
f0102cb1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102cb4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102cb8:	0f 8e 94 00 00 00    	jle    f0102d52 <vprintfmt+0x225>
f0102cbe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102cc2:	0f 84 98 00 00 00    	je     f0102d60 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cc8:	83 ec 08             	sub    $0x8,%esp
f0102ccb:	ff 75 d0             	pushl  -0x30(%ebp)
f0102cce:	57                   	push   %edi
f0102ccf:	e8 5f 03 00 00       	call   f0103033 <strnlen>
f0102cd4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102cd7:	29 c1                	sub    %eax,%ecx
f0102cd9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102cdc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102cdf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102ce3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ce6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102ce9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102ceb:	eb 0f                	jmp    f0102cfc <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102ced:	83 ec 08             	sub    $0x8,%esp
f0102cf0:	53                   	push   %ebx
f0102cf1:	ff 75 e0             	pushl  -0x20(%ebp)
f0102cf4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cf6:	83 ef 01             	sub    $0x1,%edi
f0102cf9:	83 c4 10             	add    $0x10,%esp
f0102cfc:	85 ff                	test   %edi,%edi
f0102cfe:	7f ed                	jg     f0102ced <vprintfmt+0x1c0>
f0102d00:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d03:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d06:	85 c9                	test   %ecx,%ecx
f0102d08:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d0d:	0f 49 c1             	cmovns %ecx,%eax
f0102d10:	29 c1                	sub    %eax,%ecx
f0102d12:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d15:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d18:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d1b:	89 cb                	mov    %ecx,%ebx
f0102d1d:	eb 4d                	jmp    f0102d6c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102d1f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102d23:	74 1b                	je     f0102d40 <vprintfmt+0x213>
f0102d25:	0f be c0             	movsbl %al,%eax
f0102d28:	83 e8 20             	sub    $0x20,%eax
f0102d2b:	83 f8 5e             	cmp    $0x5e,%eax
f0102d2e:	76 10                	jbe    f0102d40 <vprintfmt+0x213>
					putch('?', putdat);
f0102d30:	83 ec 08             	sub    $0x8,%esp
f0102d33:	ff 75 0c             	pushl  0xc(%ebp)
f0102d36:	6a 3f                	push   $0x3f
f0102d38:	ff 55 08             	call   *0x8(%ebp)
f0102d3b:	83 c4 10             	add    $0x10,%esp
f0102d3e:	eb 0d                	jmp    f0102d4d <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102d40:	83 ec 08             	sub    $0x8,%esp
f0102d43:	ff 75 0c             	pushl  0xc(%ebp)
f0102d46:	52                   	push   %edx
f0102d47:	ff 55 08             	call   *0x8(%ebp)
f0102d4a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d4d:	83 eb 01             	sub    $0x1,%ebx
f0102d50:	eb 1a                	jmp    f0102d6c <vprintfmt+0x23f>
f0102d52:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d55:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d58:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d5b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d5e:	eb 0c                	jmp    f0102d6c <vprintfmt+0x23f>
f0102d60:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d63:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d66:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d69:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d6c:	83 c7 01             	add    $0x1,%edi
f0102d6f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102d73:	0f be d0             	movsbl %al,%edx
f0102d76:	85 d2                	test   %edx,%edx
f0102d78:	74 23                	je     f0102d9d <vprintfmt+0x270>
f0102d7a:	85 f6                	test   %esi,%esi
f0102d7c:	78 a1                	js     f0102d1f <vprintfmt+0x1f2>
f0102d7e:	83 ee 01             	sub    $0x1,%esi
f0102d81:	79 9c                	jns    f0102d1f <vprintfmt+0x1f2>
f0102d83:	89 df                	mov    %ebx,%edi
f0102d85:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d8b:	eb 18                	jmp    f0102da5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102d8d:	83 ec 08             	sub    $0x8,%esp
f0102d90:	53                   	push   %ebx
f0102d91:	6a 20                	push   $0x20
f0102d93:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102d95:	83 ef 01             	sub    $0x1,%edi
f0102d98:	83 c4 10             	add    $0x10,%esp
f0102d9b:	eb 08                	jmp    f0102da5 <vprintfmt+0x278>
f0102d9d:	89 df                	mov    %ebx,%edi
f0102d9f:	8b 75 08             	mov    0x8(%ebp),%esi
f0102da2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102da5:	85 ff                	test   %edi,%edi
f0102da7:	7f e4                	jg     f0102d8d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102da9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102dac:	e9 a2 fd ff ff       	jmp    f0102b53 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102db1:	83 fa 01             	cmp    $0x1,%edx
f0102db4:	7e 16                	jle    f0102dcc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102db6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102db9:	8d 50 08             	lea    0x8(%eax),%edx
f0102dbc:	89 55 14             	mov    %edx,0x14(%ebp)
f0102dbf:	8b 50 04             	mov    0x4(%eax),%edx
f0102dc2:	8b 00                	mov    (%eax),%eax
f0102dc4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dc7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102dca:	eb 32                	jmp    f0102dfe <vprintfmt+0x2d1>
	else if (lflag)
f0102dcc:	85 d2                	test   %edx,%edx
f0102dce:	74 18                	je     f0102de8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102dd0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dd3:	8d 50 04             	lea    0x4(%eax),%edx
f0102dd6:	89 55 14             	mov    %edx,0x14(%ebp)
f0102dd9:	8b 00                	mov    (%eax),%eax
f0102ddb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dde:	89 c1                	mov    %eax,%ecx
f0102de0:	c1 f9 1f             	sar    $0x1f,%ecx
f0102de3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102de6:	eb 16                	jmp    f0102dfe <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102de8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102deb:	8d 50 04             	lea    0x4(%eax),%edx
f0102dee:	89 55 14             	mov    %edx,0x14(%ebp)
f0102df1:	8b 00                	mov    (%eax),%eax
f0102df3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102df6:	89 c1                	mov    %eax,%ecx
f0102df8:	c1 f9 1f             	sar    $0x1f,%ecx
f0102dfb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102dfe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e01:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102e04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102e09:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102e0d:	79 74                	jns    f0102e83 <vprintfmt+0x356>
				putch('-', putdat);
f0102e0f:	83 ec 08             	sub    $0x8,%esp
f0102e12:	53                   	push   %ebx
f0102e13:	6a 2d                	push   $0x2d
f0102e15:	ff d6                	call   *%esi
				num = -(long long) num;
f0102e17:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e1d:	f7 d8                	neg    %eax
f0102e1f:	83 d2 00             	adc    $0x0,%edx
f0102e22:	f7 da                	neg    %edx
f0102e24:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102e27:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102e2c:	eb 55                	jmp    f0102e83 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102e2e:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e31:	e8 83 fc ff ff       	call   f0102ab9 <getuint>
			base = 10;
f0102e36:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102e3b:	eb 46                	jmp    f0102e83 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0102e3d:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e40:	e8 74 fc ff ff       	call   f0102ab9 <getuint>
			base = 8;
f0102e45:	b9 08 00 00 00       	mov    $0x8,%ecx
			//putch('\\',putdat);
			goto number;
f0102e4a:	eb 37                	jmp    f0102e83 <vprintfmt+0x356>
			//putch('X', putdat);
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0102e4c:	83 ec 08             	sub    $0x8,%esp
f0102e4f:	53                   	push   %ebx
f0102e50:	6a 30                	push   $0x30
f0102e52:	ff d6                	call   *%esi
			putch('x', putdat);
f0102e54:	83 c4 08             	add    $0x8,%esp
f0102e57:	53                   	push   %ebx
f0102e58:	6a 78                	push   $0x78
f0102e5a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102e5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e5f:	8d 50 04             	lea    0x4(%eax),%edx
f0102e62:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102e65:	8b 00                	mov    (%eax),%eax
f0102e67:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102e6c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102e6f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102e74:	eb 0d                	jmp    f0102e83 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102e76:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e79:	e8 3b fc ff ff       	call   f0102ab9 <getuint>
			base = 16;
f0102e7e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102e83:	83 ec 0c             	sub    $0xc,%esp
f0102e86:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102e8a:	57                   	push   %edi
f0102e8b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e8e:	51                   	push   %ecx
f0102e8f:	52                   	push   %edx
f0102e90:	50                   	push   %eax
f0102e91:	89 da                	mov    %ebx,%edx
f0102e93:	89 f0                	mov    %esi,%eax
f0102e95:	e8 70 fb ff ff       	call   f0102a0a <printnum>
			break;
f0102e9a:	83 c4 20             	add    $0x20,%esp
f0102e9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ea0:	e9 ae fc ff ff       	jmp    f0102b53 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102ea5:	83 ec 08             	sub    $0x8,%esp
f0102ea8:	53                   	push   %ebx
f0102ea9:	51                   	push   %ecx
f0102eaa:	ff d6                	call   *%esi
			break;
f0102eac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102eaf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102eb2:	e9 9c fc ff ff       	jmp    f0102b53 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102eb7:	83 ec 08             	sub    $0x8,%esp
f0102eba:	53                   	push   %ebx
f0102ebb:	6a 25                	push   $0x25
f0102ebd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102ebf:	83 c4 10             	add    $0x10,%esp
f0102ec2:	eb 03                	jmp    f0102ec7 <vprintfmt+0x39a>
f0102ec4:	83 ef 01             	sub    $0x1,%edi
f0102ec7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102ecb:	75 f7                	jne    f0102ec4 <vprintfmt+0x397>
f0102ecd:	e9 81 fc ff ff       	jmp    f0102b53 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ed5:	5b                   	pop    %ebx
f0102ed6:	5e                   	pop    %esi
f0102ed7:	5f                   	pop    %edi
f0102ed8:	5d                   	pop    %ebp
f0102ed9:	c3                   	ret    

f0102eda <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102eda:	55                   	push   %ebp
f0102edb:	89 e5                	mov    %esp,%ebp
f0102edd:	83 ec 18             	sub    $0x18,%esp
f0102ee0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102ee6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102ee9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102eed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102ef0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102ef7:	85 c0                	test   %eax,%eax
f0102ef9:	74 26                	je     f0102f21 <vsnprintf+0x47>
f0102efb:	85 d2                	test   %edx,%edx
f0102efd:	7e 22                	jle    f0102f21 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102eff:	ff 75 14             	pushl  0x14(%ebp)
f0102f02:	ff 75 10             	pushl  0x10(%ebp)
f0102f05:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102f08:	50                   	push   %eax
f0102f09:	68 f3 2a 10 f0       	push   $0xf0102af3
f0102f0e:	e8 1a fc ff ff       	call   f0102b2d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102f13:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f16:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f1c:	83 c4 10             	add    $0x10,%esp
f0102f1f:	eb 05                	jmp    f0102f26 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102f21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102f26:	c9                   	leave  
f0102f27:	c3                   	ret    

f0102f28 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102f28:	55                   	push   %ebp
f0102f29:	89 e5                	mov    %esp,%ebp
f0102f2b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102f2e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102f31:	50                   	push   %eax
f0102f32:	ff 75 10             	pushl  0x10(%ebp)
f0102f35:	ff 75 0c             	pushl  0xc(%ebp)
f0102f38:	ff 75 08             	pushl  0x8(%ebp)
f0102f3b:	e8 9a ff ff ff       	call   f0102eda <vsnprintf>
	va_end(ap);

	return rc;
}
f0102f40:	c9                   	leave  
f0102f41:	c3                   	ret    

f0102f42 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102f42:	55                   	push   %ebp
f0102f43:	89 e5                	mov    %esp,%ebp
f0102f45:	57                   	push   %edi
f0102f46:	56                   	push   %esi
f0102f47:	53                   	push   %ebx
f0102f48:	83 ec 0c             	sub    $0xc,%esp
f0102f4b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102f4e:	85 c0                	test   %eax,%eax
f0102f50:	74 11                	je     f0102f63 <readline+0x21>
		cprintf("%s", prompt);
f0102f52:	83 ec 08             	sub    $0x8,%esp
f0102f55:	50                   	push   %eax
f0102f56:	68 68 44 10 f0       	push   $0xf0104468
f0102f5b:	e8 80 f7 ff ff       	call   f01026e0 <cprintf>
f0102f60:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102f63:	83 ec 0c             	sub    $0xc,%esp
f0102f66:	6a 00                	push   $0x0
f0102f68:	e8 ef d6 ff ff       	call   f010065c <iscons>
f0102f6d:	89 c7                	mov    %eax,%edi
f0102f6f:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102f72:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102f77:	e8 cf d6 ff ff       	call   f010064b <getchar>
f0102f7c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102f7e:	85 c0                	test   %eax,%eax
f0102f80:	79 18                	jns    f0102f9a <readline+0x58>
			cprintf("read error: %e\n", c);
f0102f82:	83 ec 08             	sub    $0x8,%esp
f0102f85:	50                   	push   %eax
f0102f86:	68 80 49 10 f0       	push   $0xf0104980
f0102f8b:	e8 50 f7 ff ff       	call   f01026e0 <cprintf>
			return NULL;
f0102f90:	83 c4 10             	add    $0x10,%esp
f0102f93:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f98:	eb 79                	jmp    f0103013 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102f9a:	83 f8 08             	cmp    $0x8,%eax
f0102f9d:	0f 94 c2             	sete   %dl
f0102fa0:	83 f8 7f             	cmp    $0x7f,%eax
f0102fa3:	0f 94 c0             	sete   %al
f0102fa6:	08 c2                	or     %al,%dl
f0102fa8:	74 1a                	je     f0102fc4 <readline+0x82>
f0102faa:	85 f6                	test   %esi,%esi
f0102fac:	7e 16                	jle    f0102fc4 <readline+0x82>
			if (echoing)
f0102fae:	85 ff                	test   %edi,%edi
f0102fb0:	74 0d                	je     f0102fbf <readline+0x7d>
				cputchar('\b');
f0102fb2:	83 ec 0c             	sub    $0xc,%esp
f0102fb5:	6a 08                	push   $0x8
f0102fb7:	e8 7f d6 ff ff       	call   f010063b <cputchar>
f0102fbc:	83 c4 10             	add    $0x10,%esp
			i--;
f0102fbf:	83 ee 01             	sub    $0x1,%esi
f0102fc2:	eb b3                	jmp    f0102f77 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102fc4:	83 fb 1f             	cmp    $0x1f,%ebx
f0102fc7:	7e 23                	jle    f0102fec <readline+0xaa>
f0102fc9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102fcf:	7f 1b                	jg     f0102fec <readline+0xaa>
			if (echoing)
f0102fd1:	85 ff                	test   %edi,%edi
f0102fd3:	74 0c                	je     f0102fe1 <readline+0x9f>
				cputchar(c);
f0102fd5:	83 ec 0c             	sub    $0xc,%esp
f0102fd8:	53                   	push   %ebx
f0102fd9:	e8 5d d6 ff ff       	call   f010063b <cputchar>
f0102fde:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102fe1:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0102fe7:	8d 76 01             	lea    0x1(%esi),%esi
f0102fea:	eb 8b                	jmp    f0102f77 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102fec:	83 fb 0a             	cmp    $0xa,%ebx
f0102fef:	74 05                	je     f0102ff6 <readline+0xb4>
f0102ff1:	83 fb 0d             	cmp    $0xd,%ebx
f0102ff4:	75 81                	jne    f0102f77 <readline+0x35>
			if (echoing)
f0102ff6:	85 ff                	test   %edi,%edi
f0102ff8:	74 0d                	je     f0103007 <readline+0xc5>
				cputchar('\n');
f0102ffa:	83 ec 0c             	sub    $0xc,%esp
f0102ffd:	6a 0a                	push   $0xa
f0102fff:	e8 37 d6 ff ff       	call   f010063b <cputchar>
f0103004:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103007:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010300e:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103013:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103016:	5b                   	pop    %ebx
f0103017:	5e                   	pop    %esi
f0103018:	5f                   	pop    %edi
f0103019:	5d                   	pop    %ebp
f010301a:	c3                   	ret    

f010301b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010301b:	55                   	push   %ebp
f010301c:	89 e5                	mov    %esp,%ebp
f010301e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103021:	b8 00 00 00 00       	mov    $0x0,%eax
f0103026:	eb 03                	jmp    f010302b <strlen+0x10>
		n++;
f0103028:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010302b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010302f:	75 f7                	jne    f0103028 <strlen+0xd>
		n++;
	return n;
}
f0103031:	5d                   	pop    %ebp
f0103032:	c3                   	ret    

f0103033 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103033:	55                   	push   %ebp
f0103034:	89 e5                	mov    %esp,%ebp
f0103036:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103039:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010303c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103041:	eb 03                	jmp    f0103046 <strnlen+0x13>
		n++;
f0103043:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103046:	39 c2                	cmp    %eax,%edx
f0103048:	74 08                	je     f0103052 <strnlen+0x1f>
f010304a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010304e:	75 f3                	jne    f0103043 <strnlen+0x10>
f0103050:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103052:	5d                   	pop    %ebp
f0103053:	c3                   	ret    

f0103054 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103054:	55                   	push   %ebp
f0103055:	89 e5                	mov    %esp,%ebp
f0103057:	53                   	push   %ebx
f0103058:	8b 45 08             	mov    0x8(%ebp),%eax
f010305b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010305e:	89 c2                	mov    %eax,%edx
f0103060:	83 c2 01             	add    $0x1,%edx
f0103063:	83 c1 01             	add    $0x1,%ecx
f0103066:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010306a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010306d:	84 db                	test   %bl,%bl
f010306f:	75 ef                	jne    f0103060 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103071:	5b                   	pop    %ebx
f0103072:	5d                   	pop    %ebp
f0103073:	c3                   	ret    

f0103074 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103074:	55                   	push   %ebp
f0103075:	89 e5                	mov    %esp,%ebp
f0103077:	53                   	push   %ebx
f0103078:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010307b:	53                   	push   %ebx
f010307c:	e8 9a ff ff ff       	call   f010301b <strlen>
f0103081:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103084:	ff 75 0c             	pushl  0xc(%ebp)
f0103087:	01 d8                	add    %ebx,%eax
f0103089:	50                   	push   %eax
f010308a:	e8 c5 ff ff ff       	call   f0103054 <strcpy>
	return dst;
}
f010308f:	89 d8                	mov    %ebx,%eax
f0103091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103094:	c9                   	leave  
f0103095:	c3                   	ret    

f0103096 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103096:	55                   	push   %ebp
f0103097:	89 e5                	mov    %esp,%ebp
f0103099:	56                   	push   %esi
f010309a:	53                   	push   %ebx
f010309b:	8b 75 08             	mov    0x8(%ebp),%esi
f010309e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030a1:	89 f3                	mov    %esi,%ebx
f01030a3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01030a6:	89 f2                	mov    %esi,%edx
f01030a8:	eb 0f                	jmp    f01030b9 <strncpy+0x23>
		*dst++ = *src;
f01030aa:	83 c2 01             	add    $0x1,%edx
f01030ad:	0f b6 01             	movzbl (%ecx),%eax
f01030b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01030b3:	80 39 01             	cmpb   $0x1,(%ecx)
f01030b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01030b9:	39 da                	cmp    %ebx,%edx
f01030bb:	75 ed                	jne    f01030aa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01030bd:	89 f0                	mov    %esi,%eax
f01030bf:	5b                   	pop    %ebx
f01030c0:	5e                   	pop    %esi
f01030c1:	5d                   	pop    %ebp
f01030c2:	c3                   	ret    

f01030c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01030c3:	55                   	push   %ebp
f01030c4:	89 e5                	mov    %esp,%ebp
f01030c6:	56                   	push   %esi
f01030c7:	53                   	push   %ebx
f01030c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01030cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030ce:	8b 55 10             	mov    0x10(%ebp),%edx
f01030d1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01030d3:	85 d2                	test   %edx,%edx
f01030d5:	74 21                	je     f01030f8 <strlcpy+0x35>
f01030d7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01030db:	89 f2                	mov    %esi,%edx
f01030dd:	eb 09                	jmp    f01030e8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01030df:	83 c2 01             	add    $0x1,%edx
f01030e2:	83 c1 01             	add    $0x1,%ecx
f01030e5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01030e8:	39 c2                	cmp    %eax,%edx
f01030ea:	74 09                	je     f01030f5 <strlcpy+0x32>
f01030ec:	0f b6 19             	movzbl (%ecx),%ebx
f01030ef:	84 db                	test   %bl,%bl
f01030f1:	75 ec                	jne    f01030df <strlcpy+0x1c>
f01030f3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01030f5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01030f8:	29 f0                	sub    %esi,%eax
}
f01030fa:	5b                   	pop    %ebx
f01030fb:	5e                   	pop    %esi
f01030fc:	5d                   	pop    %ebp
f01030fd:	c3                   	ret    

f01030fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01030fe:	55                   	push   %ebp
f01030ff:	89 e5                	mov    %esp,%ebp
f0103101:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103104:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103107:	eb 06                	jmp    f010310f <strcmp+0x11>
		p++, q++;
f0103109:	83 c1 01             	add    $0x1,%ecx
f010310c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010310f:	0f b6 01             	movzbl (%ecx),%eax
f0103112:	84 c0                	test   %al,%al
f0103114:	74 04                	je     f010311a <strcmp+0x1c>
f0103116:	3a 02                	cmp    (%edx),%al
f0103118:	74 ef                	je     f0103109 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010311a:	0f b6 c0             	movzbl %al,%eax
f010311d:	0f b6 12             	movzbl (%edx),%edx
f0103120:	29 d0                	sub    %edx,%eax
}
f0103122:	5d                   	pop    %ebp
f0103123:	c3                   	ret    

f0103124 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103124:	55                   	push   %ebp
f0103125:	89 e5                	mov    %esp,%ebp
f0103127:	53                   	push   %ebx
f0103128:	8b 45 08             	mov    0x8(%ebp),%eax
f010312b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010312e:	89 c3                	mov    %eax,%ebx
f0103130:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103133:	eb 06                	jmp    f010313b <strncmp+0x17>
		n--, p++, q++;
f0103135:	83 c0 01             	add    $0x1,%eax
f0103138:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010313b:	39 d8                	cmp    %ebx,%eax
f010313d:	74 15                	je     f0103154 <strncmp+0x30>
f010313f:	0f b6 08             	movzbl (%eax),%ecx
f0103142:	84 c9                	test   %cl,%cl
f0103144:	74 04                	je     f010314a <strncmp+0x26>
f0103146:	3a 0a                	cmp    (%edx),%cl
f0103148:	74 eb                	je     f0103135 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010314a:	0f b6 00             	movzbl (%eax),%eax
f010314d:	0f b6 12             	movzbl (%edx),%edx
f0103150:	29 d0                	sub    %edx,%eax
f0103152:	eb 05                	jmp    f0103159 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103154:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103159:	5b                   	pop    %ebx
f010315a:	5d                   	pop    %ebp
f010315b:	c3                   	ret    

f010315c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010315c:	55                   	push   %ebp
f010315d:	89 e5                	mov    %esp,%ebp
f010315f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103162:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103166:	eb 07                	jmp    f010316f <strchr+0x13>
		if (*s == c)
f0103168:	38 ca                	cmp    %cl,%dl
f010316a:	74 0f                	je     f010317b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010316c:	83 c0 01             	add    $0x1,%eax
f010316f:	0f b6 10             	movzbl (%eax),%edx
f0103172:	84 d2                	test   %dl,%dl
f0103174:	75 f2                	jne    f0103168 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103176:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010317b:	5d                   	pop    %ebp
f010317c:	c3                   	ret    

f010317d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010317d:	55                   	push   %ebp
f010317e:	89 e5                	mov    %esp,%ebp
f0103180:	8b 45 08             	mov    0x8(%ebp),%eax
f0103183:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103187:	eb 03                	jmp    f010318c <strfind+0xf>
f0103189:	83 c0 01             	add    $0x1,%eax
f010318c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010318f:	38 ca                	cmp    %cl,%dl
f0103191:	74 04                	je     f0103197 <strfind+0x1a>
f0103193:	84 d2                	test   %dl,%dl
f0103195:	75 f2                	jne    f0103189 <strfind+0xc>
			break;
	return (char *) s;
}
f0103197:	5d                   	pop    %ebp
f0103198:	c3                   	ret    

f0103199 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103199:	55                   	push   %ebp
f010319a:	89 e5                	mov    %esp,%ebp
f010319c:	57                   	push   %edi
f010319d:	56                   	push   %esi
f010319e:	53                   	push   %ebx
f010319f:	8b 7d 08             	mov    0x8(%ebp),%edi
f01031a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01031a5:	85 c9                	test   %ecx,%ecx
f01031a7:	74 36                	je     f01031df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01031a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01031af:	75 28                	jne    f01031d9 <memset+0x40>
f01031b1:	f6 c1 03             	test   $0x3,%cl
f01031b4:	75 23                	jne    f01031d9 <memset+0x40>
		c &= 0xFF;
f01031b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01031ba:	89 d3                	mov    %edx,%ebx
f01031bc:	c1 e3 08             	shl    $0x8,%ebx
f01031bf:	89 d6                	mov    %edx,%esi
f01031c1:	c1 e6 18             	shl    $0x18,%esi
f01031c4:	89 d0                	mov    %edx,%eax
f01031c6:	c1 e0 10             	shl    $0x10,%eax
f01031c9:	09 f0                	or     %esi,%eax
f01031cb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01031cd:	89 d8                	mov    %ebx,%eax
f01031cf:	09 d0                	or     %edx,%eax
f01031d1:	c1 e9 02             	shr    $0x2,%ecx
f01031d4:	fc                   	cld    
f01031d5:	f3 ab                	rep stos %eax,%es:(%edi)
f01031d7:	eb 06                	jmp    f01031df <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01031d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031dc:	fc                   	cld    
f01031dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01031df:	89 f8                	mov    %edi,%eax
f01031e1:	5b                   	pop    %ebx
f01031e2:	5e                   	pop    %esi
f01031e3:	5f                   	pop    %edi
f01031e4:	5d                   	pop    %ebp
f01031e5:	c3                   	ret    

f01031e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01031e6:	55                   	push   %ebp
f01031e7:	89 e5                	mov    %esp,%ebp
f01031e9:	57                   	push   %edi
f01031ea:	56                   	push   %esi
f01031eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01031ee:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01031f4:	39 c6                	cmp    %eax,%esi
f01031f6:	73 35                	jae    f010322d <memmove+0x47>
f01031f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01031fb:	39 d0                	cmp    %edx,%eax
f01031fd:	73 2e                	jae    f010322d <memmove+0x47>
		s += n;
		d += n;
f01031ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103202:	89 d6                	mov    %edx,%esi
f0103204:	09 fe                	or     %edi,%esi
f0103206:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010320c:	75 13                	jne    f0103221 <memmove+0x3b>
f010320e:	f6 c1 03             	test   $0x3,%cl
f0103211:	75 0e                	jne    f0103221 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103213:	83 ef 04             	sub    $0x4,%edi
f0103216:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103219:	c1 e9 02             	shr    $0x2,%ecx
f010321c:	fd                   	std    
f010321d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010321f:	eb 09                	jmp    f010322a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103221:	83 ef 01             	sub    $0x1,%edi
f0103224:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103227:	fd                   	std    
f0103228:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010322a:	fc                   	cld    
f010322b:	eb 1d                	jmp    f010324a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010322d:	89 f2                	mov    %esi,%edx
f010322f:	09 c2                	or     %eax,%edx
f0103231:	f6 c2 03             	test   $0x3,%dl
f0103234:	75 0f                	jne    f0103245 <memmove+0x5f>
f0103236:	f6 c1 03             	test   $0x3,%cl
f0103239:	75 0a                	jne    f0103245 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010323b:	c1 e9 02             	shr    $0x2,%ecx
f010323e:	89 c7                	mov    %eax,%edi
f0103240:	fc                   	cld    
f0103241:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103243:	eb 05                	jmp    f010324a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103245:	89 c7                	mov    %eax,%edi
f0103247:	fc                   	cld    
f0103248:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010324a:	5e                   	pop    %esi
f010324b:	5f                   	pop    %edi
f010324c:	5d                   	pop    %ebp
f010324d:	c3                   	ret    

f010324e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010324e:	55                   	push   %ebp
f010324f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103251:	ff 75 10             	pushl  0x10(%ebp)
f0103254:	ff 75 0c             	pushl  0xc(%ebp)
f0103257:	ff 75 08             	pushl  0x8(%ebp)
f010325a:	e8 87 ff ff ff       	call   f01031e6 <memmove>
}
f010325f:	c9                   	leave  
f0103260:	c3                   	ret    

f0103261 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103261:	55                   	push   %ebp
f0103262:	89 e5                	mov    %esp,%ebp
f0103264:	56                   	push   %esi
f0103265:	53                   	push   %ebx
f0103266:	8b 45 08             	mov    0x8(%ebp),%eax
f0103269:	8b 55 0c             	mov    0xc(%ebp),%edx
f010326c:	89 c6                	mov    %eax,%esi
f010326e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103271:	eb 1a                	jmp    f010328d <memcmp+0x2c>
		if (*s1 != *s2)
f0103273:	0f b6 08             	movzbl (%eax),%ecx
f0103276:	0f b6 1a             	movzbl (%edx),%ebx
f0103279:	38 d9                	cmp    %bl,%cl
f010327b:	74 0a                	je     f0103287 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010327d:	0f b6 c1             	movzbl %cl,%eax
f0103280:	0f b6 db             	movzbl %bl,%ebx
f0103283:	29 d8                	sub    %ebx,%eax
f0103285:	eb 0f                	jmp    f0103296 <memcmp+0x35>
		s1++, s2++;
f0103287:	83 c0 01             	add    $0x1,%eax
f010328a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010328d:	39 f0                	cmp    %esi,%eax
f010328f:	75 e2                	jne    f0103273 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103291:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103296:	5b                   	pop    %ebx
f0103297:	5e                   	pop    %esi
f0103298:	5d                   	pop    %ebp
f0103299:	c3                   	ret    

f010329a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010329a:	55                   	push   %ebp
f010329b:	89 e5                	mov    %esp,%ebp
f010329d:	53                   	push   %ebx
f010329e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01032a1:	89 c1                	mov    %eax,%ecx
f01032a3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01032a6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01032aa:	eb 0a                	jmp    f01032b6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01032ac:	0f b6 10             	movzbl (%eax),%edx
f01032af:	39 da                	cmp    %ebx,%edx
f01032b1:	74 07                	je     f01032ba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01032b3:	83 c0 01             	add    $0x1,%eax
f01032b6:	39 c8                	cmp    %ecx,%eax
f01032b8:	72 f2                	jb     f01032ac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01032ba:	5b                   	pop    %ebx
f01032bb:	5d                   	pop    %ebp
f01032bc:	c3                   	ret    

f01032bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01032bd:	55                   	push   %ebp
f01032be:	89 e5                	mov    %esp,%ebp
f01032c0:	57                   	push   %edi
f01032c1:	56                   	push   %esi
f01032c2:	53                   	push   %ebx
f01032c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01032c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01032c9:	eb 03                	jmp    f01032ce <strtol+0x11>
		s++;
f01032cb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01032ce:	0f b6 01             	movzbl (%ecx),%eax
f01032d1:	3c 20                	cmp    $0x20,%al
f01032d3:	74 f6                	je     f01032cb <strtol+0xe>
f01032d5:	3c 09                	cmp    $0x9,%al
f01032d7:	74 f2                	je     f01032cb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01032d9:	3c 2b                	cmp    $0x2b,%al
f01032db:	75 0a                	jne    f01032e7 <strtol+0x2a>
		s++;
f01032dd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01032e0:	bf 00 00 00 00       	mov    $0x0,%edi
f01032e5:	eb 11                	jmp    f01032f8 <strtol+0x3b>
f01032e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01032ec:	3c 2d                	cmp    $0x2d,%al
f01032ee:	75 08                	jne    f01032f8 <strtol+0x3b>
		s++, neg = 1;
f01032f0:	83 c1 01             	add    $0x1,%ecx
f01032f3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01032f8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01032fe:	75 15                	jne    f0103315 <strtol+0x58>
f0103300:	80 39 30             	cmpb   $0x30,(%ecx)
f0103303:	75 10                	jne    f0103315 <strtol+0x58>
f0103305:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103309:	75 7c                	jne    f0103387 <strtol+0xca>
		s += 2, base = 16;
f010330b:	83 c1 02             	add    $0x2,%ecx
f010330e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103313:	eb 16                	jmp    f010332b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103315:	85 db                	test   %ebx,%ebx
f0103317:	75 12                	jne    f010332b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103319:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010331e:	80 39 30             	cmpb   $0x30,(%ecx)
f0103321:	75 08                	jne    f010332b <strtol+0x6e>
		s++, base = 8;
f0103323:	83 c1 01             	add    $0x1,%ecx
f0103326:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010332b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103330:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103333:	0f b6 11             	movzbl (%ecx),%edx
f0103336:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103339:	89 f3                	mov    %esi,%ebx
f010333b:	80 fb 09             	cmp    $0x9,%bl
f010333e:	77 08                	ja     f0103348 <strtol+0x8b>
			dig = *s - '0';
f0103340:	0f be d2             	movsbl %dl,%edx
f0103343:	83 ea 30             	sub    $0x30,%edx
f0103346:	eb 22                	jmp    f010336a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103348:	8d 72 9f             	lea    -0x61(%edx),%esi
f010334b:	89 f3                	mov    %esi,%ebx
f010334d:	80 fb 19             	cmp    $0x19,%bl
f0103350:	77 08                	ja     f010335a <strtol+0x9d>
			dig = *s - 'a' + 10;
f0103352:	0f be d2             	movsbl %dl,%edx
f0103355:	83 ea 57             	sub    $0x57,%edx
f0103358:	eb 10                	jmp    f010336a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010335a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010335d:	89 f3                	mov    %esi,%ebx
f010335f:	80 fb 19             	cmp    $0x19,%bl
f0103362:	77 16                	ja     f010337a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103364:	0f be d2             	movsbl %dl,%edx
f0103367:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010336a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010336d:	7d 0b                	jge    f010337a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010336f:	83 c1 01             	add    $0x1,%ecx
f0103372:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103376:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103378:	eb b9                	jmp    f0103333 <strtol+0x76>

	if (endptr)
f010337a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010337e:	74 0d                	je     f010338d <strtol+0xd0>
		*endptr = (char *) s;
f0103380:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103383:	89 0e                	mov    %ecx,(%esi)
f0103385:	eb 06                	jmp    f010338d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103387:	85 db                	test   %ebx,%ebx
f0103389:	74 98                	je     f0103323 <strtol+0x66>
f010338b:	eb 9e                	jmp    f010332b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010338d:	89 c2                	mov    %eax,%edx
f010338f:	f7 da                	neg    %edx
f0103391:	85 ff                	test   %edi,%edi
f0103393:	0f 45 c2             	cmovne %edx,%eax
}
f0103396:	5b                   	pop    %ebx
f0103397:	5e                   	pop    %esi
f0103398:	5f                   	pop    %edi
f0103399:	5d                   	pop    %ebp
f010339a:	c3                   	ret    
f010339b:	66 90                	xchg   %ax,%ax
f010339d:	66 90                	xchg   %ax,%ax
f010339f:	90                   	nop

f01033a0 <__udivdi3>:
f01033a0:	55                   	push   %ebp
f01033a1:	57                   	push   %edi
f01033a2:	56                   	push   %esi
f01033a3:	53                   	push   %ebx
f01033a4:	83 ec 1c             	sub    $0x1c,%esp
f01033a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01033ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01033af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01033b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01033b7:	85 f6                	test   %esi,%esi
f01033b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01033bd:	89 ca                	mov    %ecx,%edx
f01033bf:	89 f8                	mov    %edi,%eax
f01033c1:	75 3d                	jne    f0103400 <__udivdi3+0x60>
f01033c3:	39 cf                	cmp    %ecx,%edi
f01033c5:	0f 87 c5 00 00 00    	ja     f0103490 <__udivdi3+0xf0>
f01033cb:	85 ff                	test   %edi,%edi
f01033cd:	89 fd                	mov    %edi,%ebp
f01033cf:	75 0b                	jne    f01033dc <__udivdi3+0x3c>
f01033d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01033d6:	31 d2                	xor    %edx,%edx
f01033d8:	f7 f7                	div    %edi
f01033da:	89 c5                	mov    %eax,%ebp
f01033dc:	89 c8                	mov    %ecx,%eax
f01033de:	31 d2                	xor    %edx,%edx
f01033e0:	f7 f5                	div    %ebp
f01033e2:	89 c1                	mov    %eax,%ecx
f01033e4:	89 d8                	mov    %ebx,%eax
f01033e6:	89 cf                	mov    %ecx,%edi
f01033e8:	f7 f5                	div    %ebp
f01033ea:	89 c3                	mov    %eax,%ebx
f01033ec:	89 d8                	mov    %ebx,%eax
f01033ee:	89 fa                	mov    %edi,%edx
f01033f0:	83 c4 1c             	add    $0x1c,%esp
f01033f3:	5b                   	pop    %ebx
f01033f4:	5e                   	pop    %esi
f01033f5:	5f                   	pop    %edi
f01033f6:	5d                   	pop    %ebp
f01033f7:	c3                   	ret    
f01033f8:	90                   	nop
f01033f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103400:	39 ce                	cmp    %ecx,%esi
f0103402:	77 74                	ja     f0103478 <__udivdi3+0xd8>
f0103404:	0f bd fe             	bsr    %esi,%edi
f0103407:	83 f7 1f             	xor    $0x1f,%edi
f010340a:	0f 84 98 00 00 00    	je     f01034a8 <__udivdi3+0x108>
f0103410:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103415:	89 f9                	mov    %edi,%ecx
f0103417:	89 c5                	mov    %eax,%ebp
f0103419:	29 fb                	sub    %edi,%ebx
f010341b:	d3 e6                	shl    %cl,%esi
f010341d:	89 d9                	mov    %ebx,%ecx
f010341f:	d3 ed                	shr    %cl,%ebp
f0103421:	89 f9                	mov    %edi,%ecx
f0103423:	d3 e0                	shl    %cl,%eax
f0103425:	09 ee                	or     %ebp,%esi
f0103427:	89 d9                	mov    %ebx,%ecx
f0103429:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010342d:	89 d5                	mov    %edx,%ebp
f010342f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103433:	d3 ed                	shr    %cl,%ebp
f0103435:	89 f9                	mov    %edi,%ecx
f0103437:	d3 e2                	shl    %cl,%edx
f0103439:	89 d9                	mov    %ebx,%ecx
f010343b:	d3 e8                	shr    %cl,%eax
f010343d:	09 c2                	or     %eax,%edx
f010343f:	89 d0                	mov    %edx,%eax
f0103441:	89 ea                	mov    %ebp,%edx
f0103443:	f7 f6                	div    %esi
f0103445:	89 d5                	mov    %edx,%ebp
f0103447:	89 c3                	mov    %eax,%ebx
f0103449:	f7 64 24 0c          	mull   0xc(%esp)
f010344d:	39 d5                	cmp    %edx,%ebp
f010344f:	72 10                	jb     f0103461 <__udivdi3+0xc1>
f0103451:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103455:	89 f9                	mov    %edi,%ecx
f0103457:	d3 e6                	shl    %cl,%esi
f0103459:	39 c6                	cmp    %eax,%esi
f010345b:	73 07                	jae    f0103464 <__udivdi3+0xc4>
f010345d:	39 d5                	cmp    %edx,%ebp
f010345f:	75 03                	jne    f0103464 <__udivdi3+0xc4>
f0103461:	83 eb 01             	sub    $0x1,%ebx
f0103464:	31 ff                	xor    %edi,%edi
f0103466:	89 d8                	mov    %ebx,%eax
f0103468:	89 fa                	mov    %edi,%edx
f010346a:	83 c4 1c             	add    $0x1c,%esp
f010346d:	5b                   	pop    %ebx
f010346e:	5e                   	pop    %esi
f010346f:	5f                   	pop    %edi
f0103470:	5d                   	pop    %ebp
f0103471:	c3                   	ret    
f0103472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103478:	31 ff                	xor    %edi,%edi
f010347a:	31 db                	xor    %ebx,%ebx
f010347c:	89 d8                	mov    %ebx,%eax
f010347e:	89 fa                	mov    %edi,%edx
f0103480:	83 c4 1c             	add    $0x1c,%esp
f0103483:	5b                   	pop    %ebx
f0103484:	5e                   	pop    %esi
f0103485:	5f                   	pop    %edi
f0103486:	5d                   	pop    %ebp
f0103487:	c3                   	ret    
f0103488:	90                   	nop
f0103489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103490:	89 d8                	mov    %ebx,%eax
f0103492:	f7 f7                	div    %edi
f0103494:	31 ff                	xor    %edi,%edi
f0103496:	89 c3                	mov    %eax,%ebx
f0103498:	89 d8                	mov    %ebx,%eax
f010349a:	89 fa                	mov    %edi,%edx
f010349c:	83 c4 1c             	add    $0x1c,%esp
f010349f:	5b                   	pop    %ebx
f01034a0:	5e                   	pop    %esi
f01034a1:	5f                   	pop    %edi
f01034a2:	5d                   	pop    %ebp
f01034a3:	c3                   	ret    
f01034a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01034a8:	39 ce                	cmp    %ecx,%esi
f01034aa:	72 0c                	jb     f01034b8 <__udivdi3+0x118>
f01034ac:	31 db                	xor    %ebx,%ebx
f01034ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01034b2:	0f 87 34 ff ff ff    	ja     f01033ec <__udivdi3+0x4c>
f01034b8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01034bd:	e9 2a ff ff ff       	jmp    f01033ec <__udivdi3+0x4c>
f01034c2:	66 90                	xchg   %ax,%ax
f01034c4:	66 90                	xchg   %ax,%ax
f01034c6:	66 90                	xchg   %ax,%ax
f01034c8:	66 90                	xchg   %ax,%ax
f01034ca:	66 90                	xchg   %ax,%ax
f01034cc:	66 90                	xchg   %ax,%ax
f01034ce:	66 90                	xchg   %ax,%ax

f01034d0 <__umoddi3>:
f01034d0:	55                   	push   %ebp
f01034d1:	57                   	push   %edi
f01034d2:	56                   	push   %esi
f01034d3:	53                   	push   %ebx
f01034d4:	83 ec 1c             	sub    $0x1c,%esp
f01034d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01034db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01034df:	8b 74 24 34          	mov    0x34(%esp),%esi
f01034e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01034e7:	85 d2                	test   %edx,%edx
f01034e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01034ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01034f1:	89 f3                	mov    %esi,%ebx
f01034f3:	89 3c 24             	mov    %edi,(%esp)
f01034f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034fa:	75 1c                	jne    f0103518 <__umoddi3+0x48>
f01034fc:	39 f7                	cmp    %esi,%edi
f01034fe:	76 50                	jbe    f0103550 <__umoddi3+0x80>
f0103500:	89 c8                	mov    %ecx,%eax
f0103502:	89 f2                	mov    %esi,%edx
f0103504:	f7 f7                	div    %edi
f0103506:	89 d0                	mov    %edx,%eax
f0103508:	31 d2                	xor    %edx,%edx
f010350a:	83 c4 1c             	add    $0x1c,%esp
f010350d:	5b                   	pop    %ebx
f010350e:	5e                   	pop    %esi
f010350f:	5f                   	pop    %edi
f0103510:	5d                   	pop    %ebp
f0103511:	c3                   	ret    
f0103512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103518:	39 f2                	cmp    %esi,%edx
f010351a:	89 d0                	mov    %edx,%eax
f010351c:	77 52                	ja     f0103570 <__umoddi3+0xa0>
f010351e:	0f bd ea             	bsr    %edx,%ebp
f0103521:	83 f5 1f             	xor    $0x1f,%ebp
f0103524:	75 5a                	jne    f0103580 <__umoddi3+0xb0>
f0103526:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010352a:	0f 82 e0 00 00 00    	jb     f0103610 <__umoddi3+0x140>
f0103530:	39 0c 24             	cmp    %ecx,(%esp)
f0103533:	0f 86 d7 00 00 00    	jbe    f0103610 <__umoddi3+0x140>
f0103539:	8b 44 24 08          	mov    0x8(%esp),%eax
f010353d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103541:	83 c4 1c             	add    $0x1c,%esp
f0103544:	5b                   	pop    %ebx
f0103545:	5e                   	pop    %esi
f0103546:	5f                   	pop    %edi
f0103547:	5d                   	pop    %ebp
f0103548:	c3                   	ret    
f0103549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103550:	85 ff                	test   %edi,%edi
f0103552:	89 fd                	mov    %edi,%ebp
f0103554:	75 0b                	jne    f0103561 <__umoddi3+0x91>
f0103556:	b8 01 00 00 00       	mov    $0x1,%eax
f010355b:	31 d2                	xor    %edx,%edx
f010355d:	f7 f7                	div    %edi
f010355f:	89 c5                	mov    %eax,%ebp
f0103561:	89 f0                	mov    %esi,%eax
f0103563:	31 d2                	xor    %edx,%edx
f0103565:	f7 f5                	div    %ebp
f0103567:	89 c8                	mov    %ecx,%eax
f0103569:	f7 f5                	div    %ebp
f010356b:	89 d0                	mov    %edx,%eax
f010356d:	eb 99                	jmp    f0103508 <__umoddi3+0x38>
f010356f:	90                   	nop
f0103570:	89 c8                	mov    %ecx,%eax
f0103572:	89 f2                	mov    %esi,%edx
f0103574:	83 c4 1c             	add    $0x1c,%esp
f0103577:	5b                   	pop    %ebx
f0103578:	5e                   	pop    %esi
f0103579:	5f                   	pop    %edi
f010357a:	5d                   	pop    %ebp
f010357b:	c3                   	ret    
f010357c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103580:	8b 34 24             	mov    (%esp),%esi
f0103583:	bf 20 00 00 00       	mov    $0x20,%edi
f0103588:	89 e9                	mov    %ebp,%ecx
f010358a:	29 ef                	sub    %ebp,%edi
f010358c:	d3 e0                	shl    %cl,%eax
f010358e:	89 f9                	mov    %edi,%ecx
f0103590:	89 f2                	mov    %esi,%edx
f0103592:	d3 ea                	shr    %cl,%edx
f0103594:	89 e9                	mov    %ebp,%ecx
f0103596:	09 c2                	or     %eax,%edx
f0103598:	89 d8                	mov    %ebx,%eax
f010359a:	89 14 24             	mov    %edx,(%esp)
f010359d:	89 f2                	mov    %esi,%edx
f010359f:	d3 e2                	shl    %cl,%edx
f01035a1:	89 f9                	mov    %edi,%ecx
f01035a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01035ab:	d3 e8                	shr    %cl,%eax
f01035ad:	89 e9                	mov    %ebp,%ecx
f01035af:	89 c6                	mov    %eax,%esi
f01035b1:	d3 e3                	shl    %cl,%ebx
f01035b3:	89 f9                	mov    %edi,%ecx
f01035b5:	89 d0                	mov    %edx,%eax
f01035b7:	d3 e8                	shr    %cl,%eax
f01035b9:	89 e9                	mov    %ebp,%ecx
f01035bb:	09 d8                	or     %ebx,%eax
f01035bd:	89 d3                	mov    %edx,%ebx
f01035bf:	89 f2                	mov    %esi,%edx
f01035c1:	f7 34 24             	divl   (%esp)
f01035c4:	89 d6                	mov    %edx,%esi
f01035c6:	d3 e3                	shl    %cl,%ebx
f01035c8:	f7 64 24 04          	mull   0x4(%esp)
f01035cc:	39 d6                	cmp    %edx,%esi
f01035ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035d2:	89 d1                	mov    %edx,%ecx
f01035d4:	89 c3                	mov    %eax,%ebx
f01035d6:	72 08                	jb     f01035e0 <__umoddi3+0x110>
f01035d8:	75 11                	jne    f01035eb <__umoddi3+0x11b>
f01035da:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01035de:	73 0b                	jae    f01035eb <__umoddi3+0x11b>
f01035e0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01035e4:	1b 14 24             	sbb    (%esp),%edx
f01035e7:	89 d1                	mov    %edx,%ecx
f01035e9:	89 c3                	mov    %eax,%ebx
f01035eb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01035ef:	29 da                	sub    %ebx,%edx
f01035f1:	19 ce                	sbb    %ecx,%esi
f01035f3:	89 f9                	mov    %edi,%ecx
f01035f5:	89 f0                	mov    %esi,%eax
f01035f7:	d3 e0                	shl    %cl,%eax
f01035f9:	89 e9                	mov    %ebp,%ecx
f01035fb:	d3 ea                	shr    %cl,%edx
f01035fd:	89 e9                	mov    %ebp,%ecx
f01035ff:	d3 ee                	shr    %cl,%esi
f0103601:	09 d0                	or     %edx,%eax
f0103603:	89 f2                	mov    %esi,%edx
f0103605:	83 c4 1c             	add    $0x1c,%esp
f0103608:	5b                   	pop    %ebx
f0103609:	5e                   	pop    %esi
f010360a:	5f                   	pop    %edi
f010360b:	5d                   	pop    %ebp
f010360c:	c3                   	ret    
f010360d:	8d 76 00             	lea    0x0(%esi),%esi
f0103610:	29 f9                	sub    %edi,%ecx
f0103612:	19 d6                	sbb    %edx,%esi
f0103614:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103618:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010361c:	e9 18 ff ff ff       	jmp    f0103539 <__umoddi3+0x69>
